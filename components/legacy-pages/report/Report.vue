<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="service"></i>จัดการรายงาน</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-select v-model="type" placeholder="เลือกประเภทรายงาน" class="mr10">
                    <bs-option 
                        v-for="item in type_list" 
                        :key="item.value" 
                        :label="item.label" 
                        :value="item.value"
                    ></bs-option>
                </bs-select>
                <bs-input class="mr10" placeholder="กรอกรหัสเซิร์ฟเวอร์เริ่มต้น" v-model="startServerId"></bs-input>
                <bs-input class="mr10" placeholder="กรอกรหัสเซิร์ฟเวอร์สิ้นสุด" v-model="endServerId"></bs-input>
                <bs-button type="primary" @click="handleSearch(type,startServerId,endServerId,cur_page,page_size)">{{ words.button.search }}</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="serverId" label="ServerId" align="center"></bs-table-column>
                <bs-table-column prop="destUid" label="UID ผู้ถูกรายงาน" align="center"></bs-table-column>
                <bs-table-column prop="destName" label="ผู้ถูกรายงาน" align="center"></bs-table-column>
                <bs-table-column prop="type" label="ประเภท" align="center"></bs-table-column>
                <bs-table-column prop="content" label="เนื้อหารายงาน" align="center"></bs-table-column>
                <bs-table-column prop="description" label="เหตุผลในการรายงาน" align="center"></bs-table-column>
                <bs-table-column prop="time" label="เวลารายงาน" align="center"></bs-table-column>
                <bs-table-column prop="name" label="ผู้รายงาน" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button type="text" @click="handleSilence(scope.$index,scope.row)">ปิดแชต</bs-button>
                        <bs-button type="text" @click="handleFreeze(scope.$index,scope.row)">ระงับบัญชี</bs-button>
                        <bs-button type="text" @click="handleIgnore(scope.$index,scope.row)">ละเว้น</bs-button>
                    </template>
                </bs-table-column>
            </bs-table>
            <!-- 分页 -->
            <div class="pagination">
                <bs-pagination 
                    @current-change="handleCurrentChange"
                    v-model:current-page="cur_page" 
                    layout="prev, pager, next, jumper" 
                    :total="total_size" 
                    :page-size="page_size"
                ></bs-pagination>
            </div>
        </div>
        <!-- 弹窗 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" center :close-on-click-modal="false">
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <template v-if="dialogType === 'silence' || dialogType === 'freeze'">
                <bs-input class="dialog-input" :placeholder="placeholder" v-model="minutes"></bs-input>
                <bs-input class="dialog-input" :placeholder="words.tips.PleaseInputReason" v-model="reason"></bs-input>
            </template>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false">{{ words.button.no }}</bs-button>
                <bs-button type="primary" @click="handleConfirm">{{ words.button.yes }}</bs-button>
            </div></template>
        </bs-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                type: '',
                startServerId: '',
                endServerId: '',
                type_list: [{
                    value: 0,
                    label: 'ทั้งหมด'
                },{
                    value: 1,
                    label: 'ชื่อเล่นไม่เหมาะสม'
                },{
                    value: 2,
                    label: 'เผยแพร่เนื้อหาลามกหรือผิดกฎหมาย'
                },{
                    value: 3,
                    label: 'หลอกลวงเพื่อเอาเงิน'
                },{
                    value: 4,
                    label: 'ซื้อขายบัญชีที่ถูกขโมย'
                },{
                    value: 5,
                    label: 'โฆษณาหลอกลวงหรือก่อกวน'
                },{
                    value: 6,
                    label: 'อื่นๆ'
                }],
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                cur_page: 1,
                total_size: 1,
                page_size: 20,
                placeholder: "", //禁言、冻结时间提示
                minutes:undefined, //禁言、冻结时间
                reason:undefined   //禁言、冻结原因
            }
        },
        mounted () {
            
        },
        methods: {
            // 分页导航
            handleCurrentChange (cur) {
                this.handleSearch(this.type,this.startServerId,this.endServerId,cur,this.page_size);
            },
            // 查询举报
            handleSearch (type,start,end,cur_page,page_size) {
                if (this.type === '' || this.startServerId === '' || this.endServerId === '') {
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบ');
                } else {
                    var params = {
                        type: type,
                        startServerId: start,
                        endServerId: end,
                        curPage: cur_page,
                        pageSize: page_size,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/report/search', params)
                    .then((res) => {
                        if (res.data.result === 1) {
                            for (let i = 0; i < res.data.list.length; i++) {
                                let type = res.data.list[i].type
                                for (let j = 0; j < this.type_list.length; j++) {
                                    if (type == this.type_list[j].value) {
                                        res.data.list[i].type = this.type_list[j].label;
                                    }
                                }
                            }
                            this.tableData = res.data.list;
                            this.total_size = res.data.totalCount;
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                }
            },
            handleSilence (index, row) {
                // 禁言
                this.dialogType = "silence";
                this.dialogTitle = "ปิดแชต";
                this.dialogInfo = "หลังจากปิดแชต ผู้เล่นจะไม่สามารถสนทนาในเกมได้ตั้งแต่นี้ ยืนยันหรือไม่?";
                this.placeholder = this.words.tips.PleaseInputMinutes;
                this.dialogVisible = true;
                this.minutes = undefined;
                this.reason = undefined;
                this.idx = index;
            },
            handleFreeze (index, row) {
                // 冻结
                this.dialogType = "freeze";
                this.dialogTitle = "ระงับบัญชี";
                this.dialogInfo = "ยืนยันระงับบัญชีหรือไม่?";
                this.placeholder = this.words.tips.PleaseInputHours;
                this.dialogVisible = true;
                this.minutes = undefined;
                this.reason = undefined;
                this.idx = index;
            },
            handleIgnore (index, row) {
                // 忽略
                this.dialogType = "ignore";
                this.dialogTitle = "ละเว้น";
                this.dialogInfo = "ยืนยันละเว้นรายงานนี้หรือไม่?";
                this.dialogVisible = true;
                this.idx = index;
            },
            handleConfirm () {
                var self = this;
                if (this.dialogType === 'silence') { //禁言
                    if (this.minutes === undefined) {
                        BsMessage.error('กรุณาระบุจำนวนนาทีที่ต้องการปิดแชต');
                    } else {
                        var params = {
                            serverId: this.tableData[this.idx].serverId,
                            uid: this.tableData[this.idx].destUid,
                            minutes: this.minutes,
                            reason: this.reason,
                            channel: getCookie('channel')
                        }
                        this.$api.post('/api/role/unVoice', params)
                        .then((res)=> {
                            if (res.data.result === 1) {
                                BsMessage.success('ปิดแชตสำเร็จ');
                                this.dialogVisible = false;
                                this.minutes = undefined;
                                this.reason = undefined;
                                this.handleSearch (this.type,this.startServerId,this.endServerId,this.cur_page,this.page_size);
                            }
                        }).catch(function (err) {
                            console.log('fetch faild: ' + err);
                        })
                    }
                } else if (this.dialogType === 'freeze') { //冻结
                    if (this.minutes === undefined) {
                        BsMessage.error('กรุณาระบุจำนวนชั่วโมงที่ต้องการระงับบัญชี');
                    } else {
                        var params = {
                            serverId: this.tableData[this.idx].serverId,
                            uid: this.tableData[this.idx].destUid,
                            minutes: this.minutes,
                            reason: this.reason,
                            channel: getCookie('channel')
                        }
                        this.$api.post('/api/role/freeze', params)
                        .then((res)=> {
                            if (res.data.result === 1) {
                                BsMessage.success('ระงับบัญชีสำเร็จ');
                                this.dialogVisible = false;
                                this.minutes = undefined;
                                this.reason = undefined;
                                this.handleSearch (this.type,this.startServerId,this.endServerId,this.cur_page,this.page_size);
                            }
                        }).catch(function (err) {
                            console.log('fetch faild: ' + err)
                        })
                    }
                } else if (this.dialogType === 'ignore') { //忽略
                    let params = {
                        id: this.tableData[this.idx].id,
                        serverId: this.tableData[this.idx].serverId,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/report/ignore', params)
                    .then((res) => {
                        if (res.data.result === 1) {
                            BsMessage.success('ละเว้นรายงานนี้แล้ว');
                            this.dialogVisible = false;
                            this.handleSearch (this.type,this.startServerId,this.endServerId,this.cur_page,this.page_size);
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err)
                    })
                }
            }
        }
    }
</script>


