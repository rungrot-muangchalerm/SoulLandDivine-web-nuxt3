<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="rank"></i> ข้อมูลผู้เล่น</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div v-if="loading" class="alert alert-info">กำลังโหลดข้อมูลผู้เล่น...</div>
            <div v-if="!selectedServer" class="alert alert-light border text-center small">
                เลือกเซิร์ฟเวอร์จาก Navbar ด้านซ้ายเพื่อดูข้อมูลผู้เล่น
            </div>
            <div v-if="selectedServer && !loading && tableData.length === 0" class="alert alert-light border text-center">
                ไม่มีข้อมูลผู้เล่น
            </div>
            <div class="d-grid gap-2">
                <article v-for="player in tableData" :key="player.accountUid" class="card border-0 shadow-sm">
                    <div class="card-body p-3 small">
                        <div class="d-flex justify-content-between align-items-start gap-3 border-bottom pb-2 mb-2">
                            <div>
                                <h2 class="h6 mb-1 text-break">{{ player.accountId }}</h2>
                                <div class="d-flex flex-wrap align-items-center gap-2 text-body-secondary">
                                    <span>UID {{ player.accountUid }}</span>
                                    <span class="badge rounded-pill text-bg-light border text-body">{{ player.channelName }}</span>
                                </div>
                            </div>
                            <div class="text-end text-nowrap">
                                <div class="text-body-secondary">ยอดเติมรวม</div>
                                <div class="fw-semibold fs-6">{{ player.accumulateTotal }}</div>
                            </div>
                        </div>
                        <div class="row row-cols-2 row-cols-lg-3 g-2">
                            <div class="col">
                                <div class="text-body-secondary">วันที่สมัคร</div>
                                <div class="text-break">{{ player.timeCreated || '-' }}</div>
                            </div>
                            <div class="col">
                                <div class="text-body-secondary">เข้าเกมล่าสุด</div>
                                <div class="text-break">{{ player.lastLoginTime || '-' }}</div>
                            </div>
                            <div class="col">
                                <div class="text-body-secondary">จำนวนตัวละคร</div>
                                <div>{{ player.characterCount }}</div>
                            </div>
                        </div>
                        <div v-if="player.characters.length" class="mt-3 pt-2 border-top">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="fw-semibold">ตัวละคร</span>
                                <span class="text-body-secondary">{{ player.characters.length }} ตัว</span>
                            </div>
                            <div class="d-grid gap-2">
                                <section
                                    v-for="character in player.characters"
                                    :key="character.uid"
                                    class="rounded bg-body-tertiary p-2"
                                >
                                    <div class="d-flex flex-wrap align-items-center gap-2 mb-2">
                                        <span class="fw-semibold text-break">{{ character.name }}</span>
                                        <span class="badge rounded-pill text-bg-primary">Lv. {{ character.level }}</span>
                                        <span class="text-body-secondary">UID {{ character.uid }}</span>
                                        <span class="ms-auto text-nowrap">
                                            เติม <strong>{{ character.accumulateTotal }}</strong>
                                        </span>
                                    </div>
                                    <div class="row row-cols-2 row-cols-lg-4 g-2">
                                        <div class="col">
                                            <div class="text-body-secondary">สถานะออนไลน์</div>
                                            <div class="text-break">{{ character.online || '-' }}</div>
                                        </div>
                                        <div class="col">
                                            <div class="text-body-secondary">ระงับแชทถึง</div>
                                            <div class="text-break">{{ character.silenceTime || '-' }}</div>
                                        </div>
                                        <div class="col">
                                            <div class="text-body-secondary">ระงับบัญชีถึง</div>
                                            <div class="text-break">{{ character.freezeTime || '-' }}</div>
                                        </div>
                                        <div class="col">
                                            <div class="text-body-secondary">เข้าเกมล่าสุด</div>
                                            <div class="text-break">{{ character.lastLoginTime || '-' }}</div>
                                        </div>
                                        <div class="col">
                                            <div class="text-body-secondary">EXP</div>
                                            <div>{{ character.exp }}</div>
                                        </div>
                                        <div class="col">
                                            <div class="text-body-secondary">ทอง</div>
                                            <div>{{ character.gold }}</div>
                                        </div>
                                        <div class="col">
                                            <div class="text-body-secondary">เพชร</div>
                                            <div>{{ character.diamond }}</div>
                                        </div>
                                    </div>
                                    <div class="d-flex flex-wrap gap-1 mt-2 pt-2 border-top">
                                        <bs-button size="small" type="primary" @click="handleEditResources(character)">แก้ทรัพยากร</bs-button>
                                        <bs-button size="small" type="danger" @click="handleSilence(character)">{{ words.button.silence }}</bs-button>
                                        <bs-button size="small" @click="handleRemoveSilence(character)">{{ words.button.removeSilence }}</bs-button>
                                        <bs-button size="small" type="danger" @click="handleFreeze(character)">{{ words.button.freeze }}</bs-button>
                                        <bs-button size="small" @click="handleRemoveFreeze(character)">{{ words.button.removeFreeze }}</bs-button>
                                    </div>
                                </section>
                            </div>
                        </div>
                    </div>
                </article>
            </div>
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
            <div v-if="dialogType === 'resources'" class="d-grid gap-2">
                <label class="small">EXP<bs-input v-model="resourceForm.exp" type="number" min="0"></bs-input></label>
                <label class="small">ทอง<bs-input v-model="resourceForm.gold" type="number" min="0"></bs-input></label>
                <label class="small">เพชร<bs-input v-model="resourceForm.diamond" type="number" min="0"></bs-input></label>
            </div>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false">{{ words.button.no }}</bs-button>
                <bs-button type="primary" @click="handleConfirm">{{ words.button.yes }}</bs-button>
            </div></template>
        </bs-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
        setup () {
            return {
                words: createAdminWords(),
                selectedServer: useCookie('selectedServer', { default: () => '' })
            }
        },
        data () {
            return {
                tableData: [],
                page: 1,
                pageSize: 50,
                total: 0,
                loading: false,
                playerRequestId: 0,
                targetCharacter: null,
                dialogVisible: false,
                dialogTitle: "",
                dialogInfo: "",
                dialogType: "",
                placeholder: "",
                resourceForm: { exp: 0, gold: 0, diamond: 0 },
                minutes:undefined, //禁言/冻结分钟
                reason:undefined   //禁言/冻结原因
            }
        },
        watch: {
            selectedServer: {
                immediate: true,
                handler () {
                    this.page = 1;
                    this.loadPlayers();
                }
            }
        },
        methods: {
            handlePageChange (page) {
                this.page = page;
                this.loadPlayers();
            },
            loadPlayers () {
                const requestId = ++this.playerRequestId;
                if (!this.selectedServer) {
                    this.tableData = [];
                    this.total = 0;
                    this.loading = false;
                    return;
                }
                this.loading = true;
                this.$api.post('/api/players/list', {
                    serverId: this.selectedServer,
                    page: this.page
                }).then((res) => {
                    if (requestId !== this.playerRequestId) return;
                    this.tableData = res.data.data;
                    this.page = res.data.page;
                    this.pageSize = res.data.pageSize;
                    this.total = res.data.total;
                }).catch((err) => {
                    if (requestId !== this.playerRequestId) return;
                    BsMessage.error(err?.data?.statusMessage || 'โหลดข้อมูลผู้เล่นไม่สำเร็จ');
                }).finally(() => {
                    if (requestId === this.playerRequestId) this.loading = false;
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
            handleEditResources (character) {
                this.targetCharacter = character;
                this.resourceForm = {
                    exp: character.exp,
                    gold: character.gold,
                    diamond: character.diamond
                };
                this.dialogType = 'resources';
                this.dialogTitle = 'แก้ไขทรัพยากร';
                this.dialogInfo = `แก้ไขทรัพยากรของ ${character.name} (UID ${character.uid})`;
                this.dialogVisible = true;
            },
            handleConfirm () {
                if (this.dialogType === 'resources') {
                    this.$api.post('/api/players/resources', {
                        serverId: this.selectedServer,
                        uid: this.targetCharacter.uid,
                        ...this.resourceForm
                    }).then((res) => {
                        if (res.data.result === 1) {
                            BsMessage.success('บันทึกทรัพยากรสำเร็จ');
                            this.dialogVisible = false;
                            this.loadPlayers();
                        }
                    }).catch((err) => {
                        BsMessage.error(err?.data?.statusMessage || 'บันทึกทรัพยากรไม่สำเร็จ');
                    });
                } else if (this.dialogType === "禁言") {// 禁言
                    if (this.minutes === undefined) {
                        BsMessage.error('กรุณาระบุจำนวนนาทีที่ระงับการแชท');
                    } else {
                        var params = {
                            serverId: this.selectedServer,
                            uid: this.targetCharacter.uid,
                            duration: this.minutes,
                            reason: this.reason,
                            action: 'silence'
                        }
                        this.$api.post('/api/players/action', params)
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
                        serverId: this.selectedServer,
                        uid: this.targetCharacter.uid,
                        action: 'unsilence'
                    }
                    this.$api.post('/api/players/action', params)
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
                            serverId: this.selectedServer,
                            uid: this.targetCharacter.uid,
                            duration: this.minutes,
                            reason: this.reason,
                            action: 'freeze'
                        }
                        this.$api.post('/api/players/action', params)
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
                        serverId: this.selectedServer,
                        uid: this.targetCharacter.uid,
                        action: 'unfreeze'
                    }
                    this.$api.post('/api/players/action', params)
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
