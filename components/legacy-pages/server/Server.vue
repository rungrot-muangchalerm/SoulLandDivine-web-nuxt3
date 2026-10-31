<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-cpu"></i>เปิดเซิร์ฟเวอร์ด่วน</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-select class="mr10" v-model="channel" placeholder="เลือกช่องทาง">
                    <el-option
                        v-for="item in channellist" 
                        :key="item.index" 
                        :label="item.name" 
                        :value="item.index"
                    ></el-option>
                </el-select>
                <el-input class="mr10" placeholder="เซิร์ฟเวอร์เริ่มต้น" v-model="serverBegin"></el-input>
                <el-input class="mr10" placeholder="เซิร์ฟเวอร์สุดท้าย" v-model="serverEnd"></el-input>
                <el-button type="primary" icon="el-icon-search" @click="handleGetServer(cur_page,page_size,channel)">{{ words.button.search }}</el-button>
                <!-- <el-button type="danger" icon="el-icon-loading" v-if="isRefresh" @click="handleStopRefresh">停止刷新</el-button>
                <el-button type="primary" icon="el-icon-alarm-clock" v-else @click="handleRefresh">เริ่มรีเฟรช</el-button> -->
                <el-button type="danger" icon="el-icon-connection" @click="handleMaintainAllCancel" style="float:right">ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์</el-button>
                <el-button type="success" icon="el-icon-connection" @click="handleMaintainAll" style="float:right">ปรับปรุงทุกเซิร์ฟเวอร์</el-button>
                
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="serverId" label="ServerId" align="center"></el-table-column>
                <el-table-column prop="registCount" label="จำนวนผู้ลงทะเบียนเซิร์ฟเวอร์นี้" align="center"></el-table-column>
                <el-table-column prop="isRecommend" label="สถานะการแนะนำ" align="center">
                    <template slot-scope="scope">
                        <el-switch
                            v-model="scope.row.isRecommend"
                            @change="handleIsRecommend(scope.$index,scope.row)"
                            :disabled="tableData[scope.$index].isRecommend"
                        ></el-switch>
                    </template>
                </el-table-column>
                <el-table-column prop="isMainTaining" label="สถานะการปรับปรุง" align="center">
                    <template slot-scope="scope">
                        <el-switch
                            v-model="scope.row.isMainTaining"
                            @change="handleIsMaintain(scope.$index,scope.row)"
                        ></el-switch>
                    </template>
                </el-table-column>
                <el-table-column prop="isOpening" label="สถานะเซิร์ฟเวอร์" align="center">
                    <template slot-scope="scope">
                        <el-switch
                            v-model="scope.row.isOpening"
                            @change="handleIsOpen(scope.$index,scope.row)"
                        ></el-switch>
                    </template>
                </el-table-column>
            </el-table>
            <!-- 分页 -->
            <div class="pagination">
                <el-pagination 
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                    :current-page.sync="cur_page" 
                    layout="sizes, prev, pager, next, jumper" 
                    :total="total_size" 
                    :page-sizes="[10,20,50,100,200]"
                    :page-size="page_size"
                ></el-pagination>
            </div>
        </div>
        <!-- 弹窗 -->
        <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="35%" center :close-on-click-modal="false">
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <span slot="footer" class="dialog-footer">
                <el-button @click="dialogVisible = false;">ยกเลิก</el-button>
                <el-button type="primary" @click="handleConfirm">ยืนยัน</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { ElMessage } from 'element-plus'
    import { ElMessageBox } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElInput, ElOption, ElPagination, ElSelect, ElSwitch, ElTable, ElTableColumn } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElInput, ElOption, ElPagination, ElSelect, ElSwitch, ElTable, ElTableColumn },
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
                    ElMessage.error('กรุณาเลือกช่องทางให้ถูกต้อง');
                } else {
                    this.$api.post('/api/servers/getServers', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            this.tableData = res.data.serverInfos;
                            this.total_size = res.data.ServerCount;
                        } else {
                            this.tableData = [];
                            ElMessage.warning('ไม่มีข้อมูล');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                }
            },
            // 推荐状态
            handleIsRecommend (index, row) {
                row.isRecommend = !row.isRecommend;
                ElMessageBox.confirm(`เปิดการแนะนำเซิร์ฟเวอร์ ${row.serverId} หรือไม่? เมื่อเปิดแล้วจะไม่สามารถปิดด้วยตนเองได้!`,`ยืนยันการแนะนำ`,{
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
                        ElMessage.success(`เปิดการแนะนำเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                        this.handleGetServer(this.cur_page,this.page_size,this.channel);
                    } else {
                        ElMessage.error(`เปิดการแนะนำเซิร์ฟเวอร์ ${row.serverId} ไม่สำเร็จ`);
                    }
                }).catch(() => {
                    ElMessage.error(`ยกเลิกการดำเนินการ`)
                })
            },
            // 维护状态
            handleIsMaintain (index, row) {
                let flag = row.isMainTaining;
				row.isMainTaining = !row.isMainTaining;
                ElMessageBox.confirm(flag?`เปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`:`ปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`,`ยืนยันการปรับปรุง`,{
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
                        ElMessage.success(`เปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    } else if (!flag && res.result === 1) {
                        ElMessage.success(`ปิดการปรับปรุงเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    }
                    this.handleGetServer(this.cur_page,this.page_size,this.channel);
                }).catch(() => {
                    ElMessage.error(`ยกเลิกการดำเนินการ`)
                })
            },
            // 开服状态
            handleIsOpen (index, row) {
                let flag = row.isOpening;
				row.isOpening = !row.isOpening;
				ElMessageBox.confirm(flag?`เปิดเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`:`ปิดเซิร์ฟเวอร์ ${row.serverId} หรือไม่?`,`ยืนยันเปิด/ปิดเซิร์ฟเวอร์`,{
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
                        ElMessage.success(`เปิดเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    } else if (!flag && res.result === 1) {
                        ElMessage.success(`ปิดเซิร์ฟเวอร์ ${row.serverId} สำเร็จ`);
                    }
                    this.handleGetServer(this.cur_page,this.page_size,this.channel);
                }).catch(() => {
                    ElMessage.error(`ยกเลิกการดำเนินการ`)
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
                            ElMessage.success('เปิดการปรับปรุงทุกเซิร์ฟเวอร์สำเร็จ');
                            this.dialogVisible = false;
                            this.handleGetServer(this.cur_page,this.page_size,this.channel);
                        } else {
                            ElMessage.error(item.serverId + ' เปิดการปรับปรุงทุกเซิร์ฟเวอร์ไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                } else if (this.dialogType === "maintainallcancel") {
                    this.$api.post('/api/servers/isMaintainAllCancel', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            ElMessage.success('ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์สำเร็จ');
                            this.dialogVisible = false;
                            this.handleGetServer(this.cur_page,this.page_size,this.channel);
                        } else {
                            ElMessage.error(item.serverId + ' ยกเลิกการปรับปรุงทุกเซิร์ฟเวอร์ไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                }
            }
        }
    }
</script>

<style scoped>
    .handle-box {
        margin-bottom: 20px;
    }
    .submitter {
        width: 100px;
    }
    .state {
        width: 100px;
    }
    .time {
        width: 330px;
    }
    .del-dialog-cnt {
        color: red;
        text-align: center;
        margin-bottom: 20px;
        font-size: 16px;
    }
    .el-button--text {
        text-decoration: underline;
    }
    .mr10 {
        width: 15%;
    }
</style>
