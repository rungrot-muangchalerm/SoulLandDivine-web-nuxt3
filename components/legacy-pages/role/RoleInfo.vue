<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-rank"></i> ข้อมูลผู้เล่น</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
				<el-select filterable v-model="selecte_server" :placeholder="words.tips.PleaseSelectServerID" class="submitter mr10" @change="handleServerChange">
				    <el-option 
                        v-for="item in server_list" 
                        :key="item.id"
                        :label="item.name"
                        :value="item.id"
                    ></el-option>
				</el-select>
            </div>
            <el-table :data="tableData" border v-loading="loading" style="width: 100%;margin-bottom: 14px;">
                <el-table-column type="expand">
                    <template #default="scope">
                        <el-table :data="scope.row.characters" border>
                            <el-table-column prop="uid" label="รหัสตัวละคร" align="center"></el-table-column>
                            <el-table-column prop="name" label="ชื่อตัวละคร" align="center"></el-table-column>
                            <el-table-column prop="level" label="ระดับ" align="center"></el-table-column>
                            <el-table-column prop="online" label="สถานะออนไลน์" align="center"></el-table-column>
                            <el-table-column prop="silenceTime" label="ระงับแชทถึง" align="center"></el-table-column>
                            <el-table-column label="จัดการแชท" align="center" min-width="180">
                                <template #default="characterScope">
                                    <el-button size="mini" type="danger" @click="handleSilence(characterScope.row)">{{ words.button.silence }}</el-button>
                                    <el-button size="mini" @click="handleRemoveSilence(characterScope.row)">{{ words.button.removeSilence }}</el-button>
                                </template>
                            </el-table-column>
                            <el-table-column prop="freezeTime" label="ระงับบัญชีถึง" align="center"></el-table-column>
                            <el-table-column label="จัดการบัญชี" align="center" min-width="180">
                                <template #default="characterScope">
                                    <el-button size="mini" type="danger" @click="handleFreeze(characterScope.row)">{{ words.button.freeze }}</el-button>
                                    <el-button size="mini" @click="handleRemoveFreeze(characterScope.row)">{{ words.button.removeFreeze }}</el-button>
                                </template>
                            </el-table-column>
                            <el-table-column prop="exp" label="ค่าประสบการณ์" align="center"></el-table-column>
                            <el-table-column prop="gold" label="ทอง" align="center"></el-table-column>
                            <el-table-column prop="diamond" label="เพชร" align="center"></el-table-column>
                            <el-table-column prop="accumulateTotal" label="ยอดเติมตัวละคร" align="center"></el-table-column>
                        </el-table>
                    </template>
                </el-table-column>
                <el-table-column prop="accountUid" label="UID ผู้เล่น" align="center"></el-table-column>
                <el-table-column prop="accountId" label="บัญชีผู้เล่น" align="center"></el-table-column>
                <el-table-column prop="channelName" label="ช่องทาง" align="center"></el-table-column>
                <el-table-column prop="timeCreated" label="วันที่สมัคร" align="center"></el-table-column>
                <el-table-column prop="lastLoginTime" label="เข้าเกมล่าสุด" align="center"></el-table-column>
                <el-table-column prop="characterCount" label="จำนวนตัวละครในเซิร์ฟเวอร์" align="center"></el-table-column>
                <el-table-column prop="accumulateTotal" label="ยอดเติมสะสมในเซิร์ฟเวอร์" align="center"></el-table-column>
            </el-table>
            <el-pagination
                v-if="total > 0"
                :current-page="page"
                :page-size="pageSize"
                :total="total"
                layout="prev, pager, next, total"
                @current-change="handlePageChange"
            ></el-pagination>
        </div>
        <!-- 提示框 -->
        <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" center>
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <template v-if="dialogType === words.button.silence || dialogType === words.button.freeze">
                <el-input class="dialog-input" :placeholder="placeholder" v-model="minutes"></el-input>
                <el-input class="dialog-input" :placeholder="words.tips.PleaseInputReason" v-model="reason"></el-input>
            </template>
            <span slot="footer" class="dialog-footer">
                <el-button @click="dialogVisible = false">{{ words.button.no }}</el-button>
                <el-button type="primary" @click="handleConfirm">{{ words.button.yes }}</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                selecte_server: '',
                server_list: [],
                tableData: [],
                page: 1,
                pageSize: 50,
                total: 0,
                loading: false,
                targetCharacter: null,
                dialogVisible: false,
                dialogTitle: "",
                dialogInfo: "",
                dialogType: "",
                placeholder: "",
                minutes:undefined, //禁言/冻结分钟
                reason:undefined   //禁言/冻结原因
            }
        },
        mounted () {
            this.getBaseInfo();
        },
        methods: {
            getBaseInfo () {
                let params = {
                    channel: getCookie('channel')
                }
                this.$api.post('/api/characters/servers',params)
                .then((res) => {
                    this.server_list = res.data;
                }).catch((err) => {
                    ElMessage.error(err?.data?.statusMessage || 'โหลดรายชื่อเซิร์ฟเวอร์ไม่สำเร็จ');
                });
            },
            handleServerChange () {
                this.page = 1;
                this.loadPlayers();
            },
            handlePageChange (page) {
                this.page = page;
                this.loadPlayers();
            },
            loadPlayers () {
                if (!this.selecte_server) {
                    this.tableData = [];
                    this.total = 0;
                    return;
                }
                this.loading = true;
                this.$api.post('/api/players/list', {
                    serverId: this.selecte_server,
                    page: this.page,
                    channel: getCookie('channel')
                }).then((res) => {
                    this.tableData = res.data.data;
                    this.page = res.data.page;
                    this.pageSize = res.data.pageSize;
                    this.total = res.data.total;
                }).catch((err) => {
                    ElMessage.error(err?.data?.statusMessage || 'โหลดข้อมูลผู้เล่นไม่สำเร็จ');
                }).finally(() => {
                    this.loading = false;
                });
            },
            handleSilence (character) {
                this.targetCharacter = character;
                // 禁言
                this.dialogType = "禁言";
                this.dialogTitle = "ระงับการแชท";
                this.dialogInfo = "หลังระงับการแชท ผู้เล่นจะไม่สามารถพูดคุยในเกมได้ ต้องการดำเนินการหรือไม่?";
                this.placeholder = this.words.tips.PleaseInputMinutes;
                this.dialogVisible = true;
            },
            handleRemoveSilence (character) {
                this.targetCharacter = character;
                // 解除禁言
                this.dialogType = "解除禁言";
                this.dialogTitle = "ยกเลิกการระงับแชท";
                this.dialogInfo = "ต้องการยกเลิกการระงับแชทและอนุญาตให้ผู้เล่นพูดคุยในเกมอีกครั้งหรือไม่?";
                this.dialogVisible = true;
            },
            handleFreeze (character) {
                this.targetCharacter = character;
                // 冻结
                this.dialogType = "冻结";
                this.dialogTitle = "ระงับบัญชี";
                this.dialogInfo = "ต้องการระงับบัญชีหรือไม่?";
                this.placeholder = this.words.tips.PleaseInputHours;
                this.dialogVisible = true;
            },
            handleRemoveFreeze (character) {
                this.targetCharacter = character;
                // 解除冻结
                this.dialogType = "解除冻结";
                this.dialogTitle = "ยกเลิกการระงับบัญชี";
                this.dialogInfo = "ต้องการยกเลิกการระงับบัญชีหรือไม่?";
                this.dialogVisible = true;
            },
            handleConfirm () {
                if (this.dialogType === "禁言") {// 禁言
                    if (this.minutes === undefined) {
                        ElMessage.error('กรุณาระบุจำนวนนาทีที่ระงับการแชท');
                    } else {
                        var params = {
                            serverId: this.selecte_server,
                            uid: this.targetCharacter.uid,
                            minutes: this.minutes,
                            reason: this.reason,
                            channel: getCookie('channel')
                        }
                        this.$api.post('/api/role/unVoice', params)
                        .then((res)=> {
                            res = res.data;
                            if (res.result === 1) {
                                ElMessage.success('ระงับการแชทสำเร็จ');
                                this.dialogVisible = false;
                                this.minutes = undefined;
                                this.reason = undefined;
                                this.loadPlayers();
                            }
                        }).catch((err) => {
                            ElMessage.error(err?.data?.statusMessage || 'ระงับการแชทไม่สำเร็จ');
                        })
                    }
                } else if (this.dialogType === "解除禁言") {// 解除禁言
                    var params = {
                        serverId: this.selecte_server,
                        uid: this.targetCharacter.uid,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/role/voice', params)
                    .then((res)=> {
                        res = res.data;
                        if (res.result === 1) {
                            ElMessage.success('ยกเลิกการระงับแชทสำเร็จ');
                            this.dialogVisible = false;
                            this.loadPlayers();
                        }
                    }).catch((err) => {
                        ElMessage.error(err?.data?.statusMessage || 'ยกเลิกการระงับแชทไม่สำเร็จ');
                    })
                } else if (this.dialogType === "冻结") {// 冻结
                    if (this.minutes === undefined) {
                        ElMessage.error('กรุณาระบุจำนวนชั่วโมงที่ระงับบัญชี');
                    } else {
                        var params = {
                            serverId: this.selecte_server,
                            uid: this.targetCharacter.uid,
                            minutes: this.minutes,
                            reason: this.reason,
                            channel: getCookie('channel')
                        }
                        this.$api.post('/api/role/freeze', params)
                        .then((res)=> {
                            res = res.data;
                            if (res.result === 1) {
                                ElMessage.success('ระงับบัญชีสำเร็จ');
                                this.dialogVisible = false;
                                this.minutes = undefined;
                                this.reason = undefined;
                                this.loadPlayers();
                            }
                        }).catch((err) => {
                            ElMessage.error(err?.data?.statusMessage || 'ระงับบัญชีไม่สำเร็จ');
                        })
                    }
                } else if (this.dialogType === "解除冻结") {// 解除冻结
                    var params = {
                        serverId: this.selecte_server,
                        uid: this.targetCharacter.uid,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/role/unFreeze', params)
                    .then((res)=> {
                        res = res.data;
                        if (res.result === 1) {
                            ElMessage.success('ยกเลิกการระงับบัญชีสำเร็จ');
                            this.dialogVisible = false;
                            this.loadPlayers();
                        }
                    }).catch((err) => {
                        ElMessage.error(err?.data?.statusMessage || 'ยกเลิกการระงับบัญชีไม่สำเร็จ');
                    })
                }
            }
        }
    }
</script>

<style scoped>
    .handle-box {
        margin-bottom: 20px;
    }
    .role-id {
        width: 150px;
    }
    .role-name {
        width: 150px;
    }
    .dialog-input {
        margin-bottom: 15px;
    }
    .del-dialog-cnt {
        color: red;
        text-align: center;
        margin-bottom: 20px;
        font-size: 16px;
    }
</style>
