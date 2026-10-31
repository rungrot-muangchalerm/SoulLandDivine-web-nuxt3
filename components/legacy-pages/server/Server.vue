<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="cpu"></i>เปิดเซิร์ฟเวอร์ด่วน</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-select class="mr10" v-model="channel" placeholder="เลือกช่องทาง">
                    <bs-option
                        v-for="item in channellist" 
                        :key="item.index" 
                        :label="item.name" 
                        :value="item.index"
                    ></bs-option>
                </bs-select>
                <bs-input class="mr10" placeholder="เซิร์ฟเวอร์เริ่มต้น" v-model="serverBegin"></bs-input>
                <bs-input class="mr10" placeholder="เซิร์ฟเวอร์สุดท้าย" v-model="serverEnd"></bs-input>
                <bs-button type="primary" @click="handleGetServer(cur_page,page_size,channel)">{{ words.button.search }}</bs-button>
                <!-- <bs-button type="danger" v-if="isRefresh" @click="handleStopRefresh">停止刷新</bs-button>
                <bs-button type="primary" v-else @click="handleRefresh">เริ่มรีเฟรช</bs-button> -->
                <bs-button type="danger" @click="handleMaintainAllCancel" class="float-end">ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์</bs-button>
                <bs-button type="success" @click="handleMaintainAll" class="float-end">ปรับปรุงทุกเซิร์ฟเวอร์</bs-button>
                
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="serverId" label="ServerId" align="center"></bs-table-column>
                <bs-table-column prop="registCount" label="จำนวนผู้ลงทะเบียนเซิร์ฟเวอร์นี้" align="center"></bs-table-column>
                <bs-table-column prop="isRecommend" label="สถานะการแนะนำ" align="center">
                    <template #default="scope">
                        <bs-switch
                            v-model="scope.row.isRecommend"
                            @change="handleIsRecommend(scope.$index,scope.row)"
                            :disabled="tableData[scope.$index].isRecommend"
                        ></bs-switch>
                    </template>
                </bs-table-column>
                <bs-table-column prop="isMainTaining" label="สถานะการปรับปรุง" align="center">
                    <template #default="scope">
                        <bs-switch
                            v-model="scope.row.isMainTaining"
                            @change="handleIsMaintain(scope.$index,scope.row)"
                        ></bs-switch>
                    </template>
                </bs-table-column>
                <bs-table-column prop="isOpening" label="สถานะเซิร์ฟเวอร์" align="center">
                    <template #default="scope">
                        <bs-switch
                            v-model="scope.row.isOpening"
                            @change="handleIsOpen(scope.$index,scope.row)"
                        ></bs-switch>
                    </template>
                </bs-table-column>
            </bs-table>
            <!-- 分页 -->
            <div class="pagination">
                <bs-pagination 
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                    v-model:current-page="cur_page" 
                    layout="sizes, prev, pager, next, jumper" 
                    :total="total_size" 
                    :page-sizes="[10,20,50,100,200]"
                    :page-size="page_size"
                ></bs-pagination>
            </div>
        </div>
        <!-- 弹窗 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" width="35%" center :close-on-click-modal="false">
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false;">ยกเลิก</bs-button>
                <bs-button type="primary" @click="handleConfirm">ยืนยัน</bs-button>
            </div></template>
        </bs-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
import { BsMessage, BsMessageBox } from '~/utils/bootstrap-message'

    export default {
        
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                cur_page: 1,
                total_size: 1,
                page_size: 50,
                isRefresh: false,
                interval: null,
                channel: '',
                serverBegin: '',
                serverEnd: '',
                channellist: []
            }
        },
        mounted () {
            this.searchChannel();
        },
        methods: {
            // 获取渠道列表
            searchChannel () {
                this.$api.post('/api/set/searchChannel')
                .then((res) => {
                    this.channellist = res.data;
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            },
            // 分页导航
            handleSizeChange (val) {
                this.page_size = val;
                this.handleGetServer(1,val,this.channel);
            },
            handleCurrentChange (cur) {
                this.handleGetServer(cur,this.page_size,this.channel);
            },
            // 获取服务器信息
            handleGetServer (cur_page,page_size,channel) {
                let params = {
                    page: cur_page,
                    pageSize: page_size,
                    channel: channel,
                    serverBegin: this.serverBegin,
                    serverEnd: this.serverEnd
                }
                if (channel === '' || channel === undefined) {
                    BsMessage.error('กรุณาเลือกช่องทางให้ถูกต้อง');
                } else {
                    this.$api.post('/api/servers/getServers', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            this.tableData = res.data.serverInfos;
                            this.total_size = res.data.ServerCount;
                        } else {
                            this.tableData = [];
                            BsMessage.warning('ไม่มีข้อมูล');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                }
            },
            // 推荐状态
            handleIsRecommend (index, row) {
                row.isRecommend = !row.isRecommend;
                BsMessageBox.confirm(`เปิดการแนะนำเซิร์ฟเวอร์ ${row.serverId} หรือไม่? เมื่อเปิดแล้วจะไม่สามารถปิดด้วยตนเองได้!`,`ยืนยันการแนะนำ`,{
                    confirmButtonText: 'ยืนยัน',
                    cancelButtonText: 'ยกเลิก',
                    type: 'warning'
                }).then(async () => {
                    let params = {
                        recommend: row.serverId,
                        channel: this.channel
                    }
                    let res = await this.$api.post('/api/servers/isRecommend',params).then(response => response.data);
                    if (res.result === 1) {
                        BsMessage.success(`เปิดการแนะนำเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                        this.handleGetServer(this.cur_page,this.page_size,this.channel);
                    } else {
                        BsMessage.error(`เปิดการแนะนำเซิร์ฟเวอร์ ${row.serverId} ไม่สำเร็จ`);
                    }
                }).catch(() => {
                    BsMessage.error(`ยกเลิกการดำเนินการ`)
                })
            },
            // 维护状态
            handleIsMaintain (index, row) {
                let flag = row.isMainTaining;
				row.isMainTaining = !row.isMainTaining;
                BsMessageBox.confirm(flag?`เปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`:`ปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`,`ยืนยันการปรับปรุง`,{
                    confirmButtonText: 'ยืนยัน',
                    cancelButtonText: 'ยกเลิก',
                    type: 'warning'
                }).then(async () => {
                    let params = {
                        maintain: row.serverId,
                        channel: this.channel
                    }
                    let res = await this.$api.post('/api/servers/isMaintain',params).then(response => response.data);
                    if (flag && res.result === 1) {
                        BsMessage.success(`เปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    } else if (!flag && res.result === 1) {
                        BsMessage.success(`ปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    }
                    this.handleGetServer(this.cur_page,this.page_size,this.channel);
                }).catch(() => {
                    BsMessage.error(`ยกเลิกการดำเนินการ`)
                })
            },
            // 开服状态
            handleIsOpen (index, row) {
                let flag = row.isOpening;
				row.isOpening = !row.isOpening;
				BsMessageBox.confirm(flag?`เปิดเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`:`ปิดเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`,`ยืนยันเปิด/ปิดเซิร์ฟเวอร์`,{
                    confirmButtonText: 'ยืนยัน',
                    cancelButtonText: 'ยกเลิก',
                    type: 'warning'
                }).then(async () => {
                    let params = {
                        open: row.serverId,
                        channel: this.channel
                    }
                    let res = await this.$api.post('/api/servers/isOpen',params).then(response => response.data);
                    if (flag && res.result === 1) {
                        BsMessage.success(`เปิดเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    } else if (!flag && res.result === 1) {
                        BsMessage.success(`ปิดเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    }
                    this.handleGetServer(this.cur_page,this.page_size,this.channel);
                }).catch(() => {
                    BsMessage.error(`ยกเลิกการดำเนินการ`)
                })
            },
            // 开启or关闭刷新
            // 全服维护、取消
            handleMaintainAll () {
                this.dialogTitle = "ปรับปรุงทุกเซิร์ฟเวอร์";
                this.dialogInfo = "ระบบจะเปิดการปรับปรุงทุกเซิร์ฟเวอร์ ยืนยันหรือไม่?";
                this.dialogVisible = true;
                this.dialogType = "maintainall";
            },
            handleMaintainAllCancel () {
                this.dialogTitle = "ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์";
                this.dialogInfo = `ระบบจะยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์ ยืนยันหรือไม่?`;
                this.dialogVisible = true;
                this.dialogType = "maintainallcancel";
            },
            handleConfirm () {
                let self = this;
                let params = {
                    channel: this.channel
                }
                if (this.dialogType === "maintainall") {
                    this.$api.post('/api/servers/isMaintainAll', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            BsMessage.success('เปิดการปรับปรุงทุกเซิร์ฟเวอร์สำเร็จ');
                            this.dialogVisible = false;
                            this.handleGetServer(this.cur_page,this.page_size,this.channel);
                        } else {
                            BsMessage.error(item.serverId + ' เปิดการปรับปรุงทุกเซิร์ฟเวอร์ไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                } else if (this.dialogType === "maintainallcancel") {
                    this.$api.post('/api/servers/isMaintainAllCancel', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            BsMessage.success('ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์สำเร็จ');
                            this.dialogVisible = false;
                            this.handleGetServer(this.cur_page,this.page_size,this.channel);
                        } else {
                            BsMessage.error(item.serverId + ' ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์ไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                }
            }
        }
    }
</script>


