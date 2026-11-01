<template>
    <div class="email-page">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="message"></i>ส่งอีเมล</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container email-form-container">
            <section class="email-section">
                <h2 class="email-section-title">ข้อมูลอีเมล</h2>
                <div class="email-fields">
                    <label class="email-field">
                        <span>ประเภทอีเมล</span>
                        <bs-select v-model="form.emailType" @change="changeEmailType">
                            <bs-option value="" label="เลือกประเภทอีเมล"></bs-option>
                            <bs-option
                                v-for="item in type_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value"
                            ></bs-option>
                        </bs-select>
                    </label>
                    <label class="email-field">
                        <span>รหัสเทมเพลต</span>
                        <bs-input v-model="form.mailId" placeholder="กรอกรหัสเทมเพลต"></bs-input>
                    </label>
                    <label class="email-field">
                        <span>ช่องทางเกม</span>
                        <bs-select
                            v-model="selectedEmailChannel"
                            :disabled="emailChannelsLoading || emailChannels.length === 0"
                        >
                            <bs-option value="" label="เลือกช่องทางเกม"></bs-option>
                            <bs-option
                                v-for="channel in emailChannels"
                                :key="channel.index"
                                :value="channel.index"
                                :label="channel.name"
                            ></bs-option>
                        </bs-select>
                        <span v-if="emailChannelsLoading" class="email-help">กำลังโหลดช่องทาง...</span>
                        <span v-else-if="emailChannelError" class="text-danger small">{{ emailChannelError }}</span>
                    </label>
                </div>
                <div v-if="form.emailType === 'allserver'" class="email-delivery">
                    <div class="email-delivery-copy">
                        <strong>ผู้รับ</strong>
                        <span>{{ allServers ? 'ส่งถึงทุกเซิร์ฟเวอร์' : `ส่งถึงเซิร์ฟเวอร์ ${selectedServer || 'ที่เลือกในแถบด้านบน'}` }}</span>
                    </div>
                    <bs-switch
                        v-model="allServers"
                        active-text="ทุกเซิร์ฟเวอร์"
                        inactive-text="เซิร์ฟเวอร์ที่เลือก"
                    ></bs-switch>
                </div>
                <label v-else-if="form.emailType === 'personalemail'" class="email-field email-uid-field">
                    <span>UID ผู้เล่น</span>
                    <bs-input v-model="form.uidList" placeholder="กรอก UID หรือหลาย UID ตามรูปแบบที่ระบบรองรับ"></bs-input>
                </label>
            </section>

            <section class="email-section">
                <div class="email-section-heading">
                    <div>
                        <h2 class="email-section-title">ของรางวัลแนบ</h2>
                        <p class="email-help mb-0">เพิ่มได้สูงสุด 3 รายการ เลือกประเภทและ ID แล้วระบุจำนวน</p>
                    </div>
                </div>
                <div class="email-reward-list">
                    <section v-for="slot in [1, 2, 3]" :key="slot" class="email-reward-card">
                        <div class="email-reward-heading">
                            <h3>รายการ {{ slot }}</h3>
                            <span v-if="form[`rewardUid${slot}`]" class="badge text-bg-primary">
                                ID {{ form[`rewardUid${slot}`] }}
                            </span>
                            <span v-else class="badge text-bg-light">ยังไม่ได้เลือก</span>
                        </div>
                        <div class="email-reward-fields">
                            <label class="email-field">
                                <span>ประเภท</span>
                                <bs-select
                                    v-model="form[`rewardType${slot}`]"
                                    @change="handleRewardTypeChange(slot)"
                                >
                                    <bs-option value="" label="เลือกประเภทของรางวัล"></bs-option>
                                    <bs-option
                                        v-for="item in reward_list"
                                        :key="item.value"
                                        :label="item.label"
                                        :value="item.value"
                                    ></bs-option>
                                </bs-select>
                            </label>
                            <label class="email-field email-id-field">
                                <span>รหัสไอเทม</span>
                                <bs-select
                                    v-model="form[`rewardUid${slot}`]"
                                    :disabled="!form[`rewardType${slot}`] || itemCatalogLoading || Boolean(itemCatalogError)"
                                    @change="handleRewardIdChange(slot)"
                                >
                                    <bs-option
                                        value=""
                                        :label="itemCatalogLoading ? 'กำลังโหลดรายการ...' : 'เลือก ID ไอเทม'"
                                    ></bs-option>
                                    <bs-option
                                        v-for="item in itemsForType(form[`rewardType${slot}`])"
                                        :key="`${item.rewardType}:${item.id}`"
                                        :value="item.id"
                                        :label="`ID ${item.id}`"
                                    ></bs-option>
                                </bs-select>
                                <span v-if="form[`rewardType${slot}`] && !itemCatalogLoading && !itemCatalogError && !itemsForType(form[`rewardType${slot}`]).length" class="email-help">
                                    ยังไม่มี ID ประเภทนี้ในรายการร้านค้า
                                </span>
                            </label>
                            <label class="email-field email-quantity-field">
                                <span>จำนวน</span>
                                <bs-input
                                    v-model="form[`rewardNum${slot}`]"
                                    type="number"
                                    min="1"
                                    placeholder="เช่น 1"
                                ></bs-input>
                            </label>
                        </div>
                        <div v-if="form[`rewardType${slot}`] === '3' || form[`rewardType${slot}`] === '4'" class="email-advanced-fields">
                            <label
                                v-for="param in rewardParameterFields(slot)"
                                :key="param.key"
                                class="email-field"
                            >
                                <span>{{ param.label }}</span>
                                <bs-input v-model="form[param.key]" :placeholder="param.label"></bs-input>
                            </label>
                        </div>
                    </section>
                </div>
                <p class="email-help mt-3 mb-0">
                    รายการ ID มาจากรางวัลร้านค้าในฐานข้อมูล ยังไม่มีชื่อหรือรูปไอเทม
                </p>
                <div v-if="itemCatalogLoading" class="email-help mt-2">กำลังโหลดรายการ ID...</div>
                <div v-else-if="itemCatalogError" class="alert alert-danger mt-2 mb-0">{{ itemCatalogError }}</div>
            </section>

            <div class="email-actions">
                <bs-button type="primary" :loading="sending" :disabled="sending" @click="handleSendEmail">
                    {{ sending ? 'กำลังส่ง...' : 'ส่งอีเมล' }}
                </bs-button>
                <bs-button :disabled="sending" @click="handleCancle">ล้างข้อมูล</bs-button>
            </div>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
        setup () { return { words: createAdminWords(), selectedServer: useCookie('selectedServer', { default: () => '' }) } },
        data () {
            return {
                disabled: false,
                sending: false,
                allServers: false,
                type_list: [{
                    value: 'allserver',
                    label: 'อีเมลถึงทุกเซิร์ฟเวอร์'
                }, {
                    value: 'personalemail',
                    label: 'อีเมลส่วนตัว'
                }],
                itemCatalog: [],
                itemCatalogLoading: false,
                itemCatalogError: '',
                emailChannels: [],
                emailChannelsLoading: false,
                emailChannelError: '',
                selectedEmailChannel: getCookie('channel'),
                reward_list: [{
                    value: '1',
                    label: 'สกุลเงิน'
                }, {
                    value: '2',
                    label: 'ไอเทมทั่วไป'
                }, {
                    value: '3',
                    label: 'วงแหวนวิญญาณ'
                }, {
                    value: '4',
                    label: 'กระดูกวิญญาณ'
                }, {
                    value: '5',
                    label: 'อุปกรณ์'
                }, {
                    value: '6',
                    label: 'ภารกิจ'
                }, {
                    value: '9',
                    label: 'แก่นวิญญาณ'
                }, {
                    value: '11',
                    label: 'กรอบแชต'
                }, {
                    value: '13',
                    label: 'อาวุธลับ'
                }, {
                    value: '21',
                    label: 'ไข่สัตว์เลี้ยง'
                }],
                form: {
                    emailType: '',
                    mailId: '',
                    uidList: '',
                    rewardType1: '',
                    rewardUid1: '',
                    rewardNum1: '',
                    rewardParam11: '',
                    rewardParam12: '',
                    rewardParam13: '',
                    rewardType2: '',
                    rewardUid2: '',
                    rewardNum2: '',
                    rewardParam21: '',
                    rewardParam22: '',
                    rewardParam23: '',
                    rewardType3: '',
                    rewardUid3: '',
                    rewardNum3: '',
                    rewardParam31: '',
                    rewardParam32: '',
                    rewardParam33: ''
                }
            }
        },
        mounted () {
            this.loadItemCatalog()
            this.loadEmailChannels()
        },
        methods: {
            rewardParameterFields (slot) {
                const type = this.form[`rewardType${slot}`]
                if (type === '3') {
                    return [{ key: `rewardParam${slot}1`, label: 'ปี' }]
                }
                if (type === '4') {
                    return [
                        { key: `rewardParam${slot}1`, label: 'สัตว์' },
                        { key: `rewardParam${slot}2`, label: 'ตำแหน่ง' },
                        { key: `rewardParam${slot}3`, label: 'ค่าสถานะหลัก' }
                    ]
                }
                return []
            },
            async loadItemCatalog () {
                this.itemCatalogLoading = true
                this.itemCatalogError = ''
                try {
                    const response = await this.$api.post('/api/email/items')
                    this.itemCatalog = response.data
                } catch (error) {
                    this.itemCatalogError = error instanceof Error
                        ? error.message
                        : 'โหลดรายการไอเทมไม่สำเร็จ'
                } finally {
                    this.itemCatalogLoading = false
                }
            },
            async loadEmailChannels () {
                this.emailChannelsLoading = true
                this.emailChannelError = ''
                try {
                    const selectedChannel = getCookie('channel')
                    const response = await this.$api.post('/api/set/searchChannelOne', selectedChannel
                        ? { channel: selectedChannel }
                        : {})
                    this.emailChannels = response.data
                    if (!this.selectedEmailChannel && this.emailChannels.length === 1) {
                        this.selectedEmailChannel = this.emailChannels[0].index
                    }
                    if (this.selectedEmailChannel && !this.emailChannels.some(channel => channel.index === this.selectedEmailChannel)) {
                        this.selectedEmailChannel = ''
                    }
                } catch (error) {
                    this.emailChannelError = error instanceof Error
                        ? error.message
                        : 'โหลดช่องทางเกมไม่สำเร็จ'
                } finally {
                    this.emailChannelsLoading = false
                }
            },
            itemsForType (rewardType) {
                return this.itemCatalog.filter(item => item.rewardType === rewardType)
            },
            handleRewardIdChange (slot) {
                if (!this.form[`rewardUid${slot}`]) return
                this.form[`rewardNum${slot}`] = this.form[`rewardNum${slot}`] || '1'
                for (let param = 1; param <= 6; param++) {
                    const key = `rewardParam${slot}${param}`
                    if (key in this.form) this.form[key] = ''
                }
            },
            handleRewardTypeChange (slot) {
                this.form[`rewardUid${slot}`] = ''
                this.form[`rewardNum${slot}`] = ''
                for (let param = 1; param <= 6; param++) {
                    const key = `rewardParam${slot}${param}`
                    if (key in this.form) this.form[key] = ''
                }
            },
            changeEmailType () {
                this.allServers = false;
                if (this.form.emailType === 'allserver') {
                    for (const key in this.form) {
                        this.form[key] = '';
                    }
                    this.form.emailType = 'allserver';
                } else {
                    this.form.mailId = '';
                    this.form.uidList = '';
                }
            },
            buildReward (slot) {
                const id = this.form[`rewardUid${slot}`].trim()
                if (!id) return ''

                const reward = `${id}:${this.form[`rewardType${slot}`]}:${this.form[`rewardNum${slot}`]}`
                const params = [
                    this.form[`rewardParam${slot}1`],
                    this.form[`rewardParam${slot}2`],
                    this.form[`rewardParam${slot}3`],
                    this.form[`rewardParam${slot}4`],
                    this.form[`rewardParam${slot}5`],
                    this.form[`rewardParam${slot}6`]
                ];
                const firstParam = params.findIndex(param => param);
                return reward + (firstParam === -1
                    ? ''
                    : '@' + params.slice(firstParam).map(param => param || '').join(':'));
            },
            async handleSendEmail () {
                if (!this.form.emailType) {
                    BsMessage.error('กรุณาเลือกประเภทอีเมล')
                    return
                }
                if (!this.form.mailId.trim()) {
                    BsMessage.error('กรุณากรอกรหัสเทมเพลต')
                    return
                }
                if (!/^[1-9]\d*$/.test(this.form.mailId.trim()) || Number(this.form.mailId) > 2147483647) {
                    BsMessage.error('รหัสเทมเพลตต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647')
                    return
                }
                if (this.form.emailType === 'personalemail' && !this.form.uidList.trim()) {
                    BsMessage.error('กรุณากรอก UID ผู้เล่น')
                    return
                }
                if (!this.selectedEmailChannel) {
                    BsMessage.error('กรุณาเลือกช่องทางเกม')
                    return
                }
                if (this.form.emailType === 'allserver' && !this.allServers && !this.selectedServer) {
                    BsMessage.error('กรุณาเลือกเซิร์ฟเวอร์จากแถบด้านบน หรือเลือกส่งทุกเซิร์ฟเวอร์')
                    return
                }

                const rewardSlots = [1, 2, 3]
                    .map(slot => ({
                        slot,
                        id: this.form[`rewardUid${slot}`].trim(),
                        type: this.form[`rewardType${slot}`],
                        quantity: this.form[`rewardNum${slot}`].trim()
                    }))
                const incompleteReward = rewardSlots.find(reward =>
                    (reward.id || reward.type || reward.quantity)
                    && (!reward.id || !reward.type || !/^[1-9]\d*$/.test(reward.quantity)),
                )
                if (incompleteReward) {
                    BsMessage.error(`กรุณากรอกประเภท ID และจำนวนของรายการ ${incompleteReward.slot} ให้ครบ`)
                    return
                }

                const rewards = rewardSlots.map(reward => this.buildReward(reward.slot))
                const params = this.form.emailType === 'allserver'
                    ? {
                        channel: this.selectedEmailChannel,
                        emailType: this.form.emailType,
                        mailId: this.form.mailId.trim(),
                        serverId: this.allServers ? '0' : this.selectedServer,
                        reward1: rewards[0],
                        reward2: rewards[1],
                        reward3: rewards[2]
                    }
                    : {
                        channel: this.selectedEmailChannel,
                        emailType: this.form.emailType,
                        mailId: this.form.mailId.trim(),
                        serverId: 'list',
                        uidList: this.form.uidList.trim(),
                        reward1: rewards[0],
                        reward2: rewards[1],
                        reward3: rewards[2]
                    }

                this.sending = true
                try {
                    const response = await this.$api.post('/api/email/send', params)
                    const result = typeof response.data === 'string'
                        ? JSON.parse(response.data)
                        : response.data
                    if (result?.result === 1) {
                        BsMessage.success('ส่งอีเมลสำเร็จ')
                        this.handleCancle()
                    } else {
                        BsMessage.error(result?.message || 'ส่งอีเมลไม่สำเร็จ กรุณาตรวจสอบข้อมูลและลองอีกครั้ง')
                    }
                } catch (error) {
                    BsMessage.error(error instanceof Error ? error.message : 'ส่งอีเมลไม่สำเร็จ')
                } finally {
                    this.sending = false
                }
            },
            handleCancle () {
                this.allServers = false;
                for (const key in this.form) {
                    this.form[key] = '';
                }
            }
        }
    }
</script>

<style scoped>
.email-page {
    padding-bottom: 2rem;
}

.email-form-container {
    display: grid;
    gap: 1.25rem;
    max-width: 980px;
    padding: 0;
}

.email-section {
    padding: 1.25rem;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.75rem;
    background: var(--bs-body-bg);
}

.email-section-title {
    margin: 0;
    font-size: 1.1rem;
    font-weight: 650;
}

.email-section-heading,
.email-reward-heading,
.email-delivery {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
}

.email-fields,
.email-reward-fields,
.email-advanced-fields {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
    margin-top: 1rem;
}

.email-reward-fields {
    grid-template-columns: minmax(170px, 0.8fr) minmax(260px, 1.5fr) minmax(120px, 0.5fr);
}

.email-advanced-fields {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    padding-top: 1rem;
    border-top: 1px solid var(--bs-border-color);
}

.email-field {
    display: grid;
    align-content: start;
    gap: 0.4rem;
    min-width: 0;
    font-size: 0.9rem;
    font-weight: 600;
}

.email-delivery {
    justify-content: flex-start;
    margin-top: 1rem;
    padding: 0.85rem 1rem;
    border-radius: 0.5rem;
    background: var(--bs-tertiary-bg);
}

.email-delivery-copy {
    display: grid;
    gap: 0.2rem;
    margin-right: auto;
}

.email-delivery-copy span,
.email-help {
    color: var(--bs-secondary-color);
    font-size: 0.875rem;
    font-weight: 400;
}

.email-reward-list {
    display: grid;
    gap: 0.75rem;
    margin-top: 1rem;
}

.email-reward-card {
    padding: 1rem;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.65rem;
    background: var(--bs-tertiary-bg);
}

.email-reward-heading {
    justify-content: flex-start;
}

.email-reward-heading h3 {
    margin: 0;
    font-size: 0.98rem;
    font-weight: 650;
}

.email-actions {
    display: flex;
    gap: 0.5rem;
}

@media (max-width: 767.98px) {
    .email-form-container {
        padding: 0 0.75rem;
    }

    .email-section {
        padding: 1rem;
    }

    .email-fields,
    .email-reward-fields,
    .email-advanced-fields {
        grid-template-columns: 1fr;
    }

    .email-section-heading,
    .email-delivery {
        align-items: flex-start;
    }
}
</style>
