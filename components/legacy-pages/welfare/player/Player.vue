<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="present"></i>จัดการของรางวัล</bs-breadcrumb-item>
                <bs-breadcrumb-item>จัดการผู้เล่น</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-button type="success" @click="handleAdd()">{{ words.button.add }}</bs-button>
                <bs-select filterable v-model="selceted_serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                    <bs-option 
                        v-for="item in server_list" 
                        :key="item.$.id" 
                        :label="item.$.name" 
                        :value="item.$.id"
                    ></bs-option>
                </bs-select>
                <bs-input class="uid mr10" placeholder="กรอก UID" v-model="selceted_uid"></bs-input>
                <bs-button type="primary" @click="handleSearch(selceted_serverId,selceted_uid)">{{ words.button.search }}</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="serverId" label="รหัสเซิร์ฟเวอร์" align="center"></bs-table-column>
                <bs-table-column prop="uid" label="uid" align="center"></bs-table-column>
                <bs-table-column prop="id" label="รหัสของรางวัล" align="center"></bs-table-column>
                <bs-table-column prop="name" label="ชื่อของรางวัล" align="center"></bs-table-column>
                <bs-table-column prop="LastTime" label="เวลามอบของรางวัลล่าสุด" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button type="text" @click="handleDelete(scope.$index,scope.row)">ลบ</bs-button>
                    </template>
                </bs-table-column>
            </bs-table>
            <!-- <div class="pagination">
                <bs-pagination @current-change="handleCurrentChange" layout="prev, pager, next" :total="1000">
                </bs-pagination>
            </div> -->
        </div>
        <!-- 弹窗 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" width="35%" :close-on-click-modal="false">
            <div class="del-dialog-cnt" v-if="this.dialogType === 'delete'">{{ dialogInfo }}</div>
            <bs-form :model="form" label-width="120px" v-if="this.dialogType === 'add'">
                <bs-form-item label="ข้อมูลผู้เล่น">
                    <bs-input
                        type="textarea"
                        autosize
                        placeholder="รูปแบบข้อมูล serverId:uid|serverId:uid"
                        v-model="form.players"
                    ></bs-input>
                </bs-form-item>
                <bs-form-item label="รหัสของรางวัล">
                    <bs-input v-model="form.welfareId" placeholder="กรอกรหัสของรางวัล"></bs-input>
                </bs-form-item>
            </bs-form>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false">ยกเลิก</bs-button>
                <bs-button type="primary" @click="handleConfirm()">ยืนยัน</bs-button>
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
                selceted_serverId: '',
                selceted_uid: '',
                server_list: [],
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    id: '',
                    serverId: '',
                    uid: '',
                    welfareId: '',
                    welfareName: '',
                    nextTime: '',
                    players: ''
                }
            }
        },
        mounted () {
            // this.handleSearch(0,0);
            this.getBaseInfo();
        },
        methods: {
            getBaseInfo () {
                let params = {
                    channel: getCookie('channel')
                }
                // 查询服务器列表
                this.$api.post('/api/baseinfo/serverlist',params)
                .then((res) => {
                    this.server_list = res.data.idspace.class;
                }).catch(function (err) {
                    console.log('fetch faild: ' + err);
                });
            },
            // 查询指定条件玩家
            handleSearch (server,id) {
                if (server === '' && id === '') {
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาอย่างน้อยหนึ่งรายการ');
                } else {
                    var params = {
                        serverId: server,
                        uid: id,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/welfare/searchPlayer', params)
                    .then((res) => {
                        this.tableData = res.data.list;
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                }
            },
            // 点击添加按钮时打开新增弹窗面板
            handleAdd () {
                this.dialogType = 'add';
                this.dialogTitle = 'มอบของรางวัลให้ผู้เล่น';
                this.dialogVisible = true;
                this.form = {
                    players: '',
                    welfareId: ''
                }
            },
            // 点击删除按钮时打开删除提示面板
            handleDelete (index, row) {
                this.dialogType = 'delete';
                this.dialogTitle = 'ลบการมอบของรางวัลให้ผู้เล่น';
                this.dialogVisible = true;
                this.idx = index;
                const item = this.tableData[index];
                this.form = {
                    serverId: item.serverId,
                    uid: item.uid,
                    welfareId: item.id,
                    channel: getCookie('channel')
                }
                this.dialogInfo = 'ต้องการลบ' + item.serverId + ' ผู้เล่นเซิร์ฟเวอร์ ' + item.uid + ' หมายเลข ' + item.id + ' ของรางวัลหรือไม่?';
            },
            // 点击弹窗面板中的确认按钮
            handleConfirm () {
                var self = this;
                if (this.dialogType === 'add') { 
                    // 添加玩家
                    if (this.isEmpty(this.form) === true) {
                        let serverList = this.splitServerUid(this.form.players,'server');
                        let uidList = this.splitServerUid(this.form.players,'uid');
                        if (serverList.length === uidList.length) {
                            let count = 0;
                            for (let i = 0; i < serverList.length; i++) {
                                let params = {
                                    serverId: serverList[i],
                                    uid: uidList[i],
                                    welfareId: this.form.welfareId,
                                    channel: getCookie('channel')
                                }
                                console.log(params)
                                self.$api.post('/api/welfare/addPlayer', params)
                                .then(function (res) {
                                    console.log(res.data)
                                    if (res.data.result === 1) {
                                        count ++;
                                        if (count === serverList.length) {
                                            BsMessage.success('มอบของรางวัลสำเร็จ');
                                            self.dialogVisible = false;
                                            // self.handleSearch(0,0);
                                        } else {
                                            console.log(count)
                                        }
                                    }
                                }).catch(function (err) {
                                    console.log('fetch faild: ' + err);
                                });
                            }
                        }
                    }
                } else if (this.dialogType === 'delete') { 
                    // 删除玩家
                    this.$api.post('/api/welfare/deletePlayer', this.form)
                    .then((res) => {
                        if (res.data.result === 1) {
                            BsMessage.success('ลบสำเร็จ');
                            this.dialogVisible = false;
                            // this.handleSearch(this.form.serverId,'');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err)
                    })
                }
            },
            // 判断传入参数属性是否有空
            isEmpty (obj) {
                for (var value in obj) {
                    if (!obj[value]) {
                        BsMessage.error("มีช่องว่างที่ยังไม่ได้กรอก กรุณากรอกข้อมูลของรางวัลให้ครบ!");
                        return false;
                    }
                }
                return true;
            },
            // 将字符串拆分为serverid和uid
            splitServerUid (str,type) {
                let serverlist = [];
                let uidlist = [];
                let arr = str ? str.split('|') : [];
                if (arr.length > 0) {
                    arr.forEach(item => {
                        if (item) {
                            let newArr = item.split(':')
                            if (newArr && newArr.length > 0) {
                                let key = newArr[0].trim();
                                let value = newArr[1] ? newArr[1].trim() : undefined;
                                serverlist.push(key);
                                uidlist.push(value);
                            }
                        }
                    })
                }
                if (type === 'server') {
                    return serverlist;
                } else if (type === 'uid') {
                    return uidlist;
                }
            } 
        }
    }
</script>


