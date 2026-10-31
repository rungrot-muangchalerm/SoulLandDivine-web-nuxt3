<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="rank"></i> ข้อมูลผู้เล่น</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
				<bs-select filterable v-model="selecte_server" :placeholder="words.tips.PleaseSelectServerID" class="submitter mr10" @change="handleServerChange">
				    <bs-option 
                        v-for="item in server_list" 
                        :key="item.id"
                        :label="item.name"
                        :value="item.id"
                    ></bs-option>
				</bs-select>
            </div>
            <div v-if="loading" class="alert alert-info">กำลังโหลดข้อมูลผู้เล่น...</div>
            <bs-table :data="tableData" border class="w-100">
                <bs-table-column type="expand">
                    <template #default="scope">
                        <bs-table :data="scope.row.characters" border>
                            <bs-table-column prop="uid" label="รหัสตัวละคร" align="center"></bs-table-column>
                            <bs-table-column prop="name" label="ชื่อตัวละคร" align="center"></bs-table-column>
                            <bs-table-column prop="level" label="ระดับ" align="center"></bs-table-column>
                            <bs-table-column prop="online" label="สถานะออนไลน์" align="center"></bs-table-column>
                            <bs-table-column prop="silenceTime" label="ระงับแชทถึง" align="center"></bs-table-column>
                            <bs-table-column label="จัดการแชท" align="center" min-width="180">
                                <template #default="characterScope">
                                    <bs-button size="small" type="danger" @click="handleSilence(characterScope.row)">{{ words.button.silence }}</bs-button>
                                    <bs-button size="small" @click="handleRemoveSilence(characterScope.row)">{{ words.button.removeSilence }}</bs-button>
                                </template>
                            </bs-table-column>
                            <bs-table-column prop="freezeTime" label="ระงับบัญชีถึง" align="center"></bs-table-column>
                            <bs-table-column label="จัดการบัญชี" align="center" min-width="180">
                                <template #default="characterScope">
                                    <bs-button size="small" type="danger" @click="handleFreeze(characterScope.row)">{{ words.button.freeze }}</bs-button>
                                    <bs-button size="small" @click="handleRemoveFreeze(characterScope.row)">{{ words.button.removeFreeze }}</bs-button>
                                </template>
                            </bs-table-column>
                            <bs-table-column prop="exp" label="ค่าประสบการณ์" align="center"></bs-table-column>
                            <bs-table-column prop="gold" label="ทอง" align="center"></bs-table-column>
                            <bs-table-column prop="diamond" label="เพชร" align="center"></bs-table-column>
                            <bs-table-column prop="accumulateTotal" label="ยอดเติมตัวละคร" align="center"></bs-table-column>
                        </bs-table>
                    </template>
                </bs-table-column>
                <bs-table-column prop="accountUid" label="UID ผู้เล่น" align="center"></bs-table-column>
                <bs-table-column prop="accountId" label="บัญชีผู้เล่น" align="center"></bs-table-column>
                <bs-table-column prop="channelName" label="ช่องทาง" align="center"></bs-table-column>
                <bs-table-column prop="timeCreated" label="วันที่สมัคร" align="center"></bs-table-column>
                <bs-table-column prop="lastLoginTime" label="เข้าเกมล่าสุด" align="center"></bs-table-column>
                <bs-table-column prop="characterCount" label="จำนวนตัวละครในเซิร์ฟเวอร์" align="center"></bs-table-column>
                <bs-table-column prop="accumulateTotal" label="ยอดเติมสะสมในเซิร์ฟเวอร์" align="center"></bs-table-column>
            </bs-table>
            <bs-pagination
                v-if="total > 0"
                :current-page="page"
                :page-size="pageSize"
                :total="total"
                layout="prev, pager, next, total"
                @current-change="handlePageChange"
            ></bs-pagination>
        </div>
        <!-- 提示框 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" center>
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <template v-if="dialogType === words.button.silence || dialogType === words.button.freeze">
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
    import { getCookie } from '~/utils/cookies'
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
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
                    BsMessage.error(err?.data?.statusMessage || 'โหลดรายชื่อเซิร์ฟเวอร์ไม่สำเร็จ');
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
                    BsMessage.error(err?.data?.statusMessage || 'โหลดข้อมูลผู้เล่นไม่สำเร็จ');
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
                        BsMessage.error('กรุณาระบุจำนวนนาทีที่ระงับการแชท');
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
                                BsMessage.success('ระงับการแชทสำเร็จ');
                                this.dialogVisible = false;
                                this.minutes = undefined;
                                this.reason = undefined;
                                this.loadPlayers();
                            }
                        }).catch((err) => {
                            BsMessage.error(err?.data?.statusMessage || 'ระงับการแชทไม่สำเร็จ');
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
                            BsMessage.success('ยกเลิกการระงับแชทสำเร็จ');
                            this.dialogVisible = false;
                            this.loadPlayers();
                        }
                    }).catch((err) => {
                        BsMessage.error(err?.data?.statusMessage || 'ยกเลิกการระงับแชทไม่สำเร็จ');
                    })
                } else if (this.dialogType === "冻结") {// 冻结
                    if (this.minutes === undefined) {
                        BsMessage.error('กรุณาระบุจำนวนชั่วโมงที่ระงับบัญชี');
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
                                BsMessage.success('ระงับบัญชีสำเร็จ');
                                this.dialogVisible = false;
                                this.minutes = undefined;
                                this.reason = undefined;
                                this.loadPlayers();
                            }
                        }).catch((err) => {
                            BsMessage.error(err?.data?.statusMessage || 'ระงับบัญชีไม่สำเร็จ');
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
                            BsMessage.success('ยกเลิกการระงับบัญชีสำเร็จ');
                            this.dialogVisible = false;
                            this.loadPlayers();
                        }
                    }).catch((err) => {
                        BsMessage.error(err?.data?.statusMessage || 'ยกเลิกการระงับบัญชีไม่สำเร็จ');
                    })
                }
            }
        }
    }
</script>


