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
                        <bs-select v-model="form.mailId" :disabled="emailTemplatesLoading || emailTemplates.length === 0">
                            <bs-option value="" label="เลือก Email template"></bs-option>
                            <bs-option
                                v-for="template in emailTemplates"
                                :key="template.id"
                                :value="String(template.id)"
                                :label="`#${template.id} — ${template.title || 'ไม่มีชื่อ'}`"
                            ></bs-option>
                        </bs-select>
                        <span v-if="emailTemplatesLoading" class="email-help">กำลังโหลด Email template...</span>
                        <span v-else-if="emailTemplatesError" class="text-danger small">{{ emailTemplatesError }}</span>
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
                <div v-if="selectedEmailTemplate" class="email-template-info">
                    <strong>{{ selectedEmailTemplate.title || `Email template #${selectedEmailTemplate.id}` }}</strong>
                    <span v-if="selectedEmailTemplate.reward">
                        มีรางวัลตั้งต้น: {{ selectedEmailTemplate.reward }}
                    </span>
                    <span v-else>ไม่มีรางวัลตั้งต้น</span>
                    <span v-if="selectedRewards.length">
                        เมื่อเลือกไอเทมด้านล่าง รางวัลที่เลือกจะแทนรางวัลตั้งต้นของ template
                    </span>
                </div>
                <label v-if="form.emailType === 'personalemail'" class="email-field email-uid-field">
                    <span>UID ผู้เล่น</span>
                    <bs-input v-model="form.uidList" placeholder="กรอก UID หรือหลาย UID ตามรูปแบบที่ระบบรองรับ"></bs-input>
                </label>
            </section>

            <section class="email-section">
                <div class="email-section-heading">
                    <div>
                        <h2 class="email-section-title">ของรางวัลแนบ</h2>
                        <p class="email-help mb-0">ติ๊กเลือกไอเทมได้หลายรายการ แล้วกำหนดจำนวนแยกแต่ละชิ้น</p>
                    </div>
                </div>
                <div class="email-reward-picker">
                    <label class="email-field email-reward-type">
                        <span>ประเภทไอเทม</span>
                        <bs-select v-model="selectedRewardType">
                            <bs-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value"
                            ></bs-option>
                        </bs-select>
                    </label>
                    <div class="email-reward-picker-actions">
                        <button
                            type="button"
                            class="btn btn-sm btn-outline-primary"
                            :disabled="itemCatalogLoading || !itemsForType(selectedRewardType).length"
                            @click="setCurrentTypeSelection(true)"
                        >
                            เลือกทั้งหมด
                        </button>
                        <button
                            type="button"
                            class="btn btn-sm btn-outline-secondary"
                            :disabled="!itemsForType(selectedRewardType).some(item => isRewardSelected(item))"
                            @click="setCurrentTypeSelection(false)"
                        >
                            ล้างประเภทนี้
                        </button>
                        <span class="badge text-bg-primary">เลือกแล้ว {{ selectedRewards.length }} รายการ</span>
                    </div>
                </div>
                <div v-if="!itemCatalogLoading && !itemCatalogError && itemsForType(selectedRewardType).length" class="email-catalog-list">
                    <div v-for="item in itemsForType(selectedRewardType)" :key="`${item.rewardType}:${item.id}`" class="email-catalog-item">
                        <label class="email-catalog-choice">
                            <input
                                class="form-check-input"
                                type="checkbox"
                                :checked="isRewardSelected(item)"
                                @change="toggleReward(item, $event.target.checked)"
                            >
                            <span>ID {{ item.id }}</span>
                        </label>
                        <div v-if="selectedReward(item)" class="email-selected-options">
                            <label class="email-field email-quantity-field">
                                <span>จำนวน</span>
                                <input
                                    v-model="selectedReward(item).quantity"
                                    class="form-control form-control-sm"
                                    type="number"
                                    min="1"
                                    placeholder="เช่น 1"
                                >
                            </label>
                            <div
                                v-if="rewardParameterFields(item.rewardType).length"
                                class="email-advanced-fields"
                            >
                                <label
                                    v-for="param in rewardParameterFields(item.rewardType)"
                                    :key="param.index"
                                    class="email-field"
                                >
                                    <span>{{ param.label }}</span>
                                    <input
                                        v-model="selectedReward(item).params[param.index]"
                                        class="form-control form-control-sm"
                                        :placeholder="param.label"
                                    >
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div v-else-if="!itemCatalogLoading && !itemCatalogError" class="email-help mt-3">
                    ยังไม่มี ID ประเภทนี้ในรายการร้านค้า
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
                selectedRewardType: '2',
                selectedRewards: [],
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
                emailTemplates: [],
                emailTemplatesLoading: false,
                emailTemplatesError: '',
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
                    uidList: ''
                }
            }
        },
        mounted () {
            this.loadItemCatalog()
            this.loadEmailTemplates()
            this.loadEmailChannels()
        },
        computed: {
            selectedEmailTemplate () {
                return this.emailTemplates.find(template => String(template.id) === this.form.mailId)
            }
        },
        methods: {
            rewardParameterFields (rewardType) {
                if (rewardType === '3') {
                    return [{ index: 0, label: 'ปี' }]
                }
                if (rewardType === '4') {
                    return [
                        { index: 0, label: 'สัตว์' },
                        { index: 1, label: 'ตำแหน่ง' },
                        { index: 2, label: 'ค่าสถานะหลัก' }
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
            async loadEmailTemplates () {
                this.emailTemplatesLoading = true
                this.emailTemplatesError = ''
                try {
                    const response = await this.$api.post('/api/email/templates')
                    this.emailTemplates = response.data
                } catch (error) {
                    this.emailTemplatesError = error instanceof Error
                        ? error.message
                        : 'โหลด Email template ไม่สำเร็จ'
                } finally {
                    this.emailTemplatesLoading = false
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
            rewardKey (item) {
                return `${item.rewardType}:${item.id}`
            },
            isRewardSelected (item) {
                return this.selectedRewards.some(reward => reward.key === this.rewardKey(item))
            },
            selectedReward (item) {
                return this.selectedRewards.find(reward => reward.key === this.rewardKey(item))
            },
            toggleReward (item, checked) {
                const key = this.rewardKey(item)
                if (checked && !this.isRewardSelected(item)) {
                    this.selectedRewards.push({
                        key,
                        id: item.id,
                        rewardType: item.rewardType,
                        quantity: '1',
                        params: ['', '', '']
                    })
                } else if (!checked) {
                    this.selectedRewards = this.selectedRewards.filter(reward => reward.key !== key)
                }
            },
            setCurrentTypeSelection (checked) {
                for (const item of this.itemsForType(this.selectedRewardType)) {
                    this.toggleReward(item, checked)
                }
            },
            changeEmailType () {
                this.allServers = false;
                if (this.form.emailType === 'allserver') {
                    for (const key in this.form) {
                        this.form[key] = '';
                    }
                    this.selectedRewards = [];
                    this.form.emailType = 'allserver';
                } else {
                    this.form.mailId = '';
                    this.form.uidList = '';
                }
            },
            buildReward (rewardItem) {
                const reward = `${rewardItem.id}:${rewardItem.rewardType}:${String(rewardItem.quantity ?? '').trim()}`
                const params = rewardItem.params;
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
                    BsMessage.error('กรุณาเลือก Email template')
                    return
                }
                if (!this.emailTemplates.some(template => String(template.id) === this.form.mailId.trim())) {
                    BsMessage.error('Email template ที่เลือกไม่มีอยู่ กรุณาโหลดรายการใหม่')
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

                const incompleteReward = this.selectedRewards.find(reward =>
                    !/^[1-9]\d*$/.test(String(reward.quantity ?? '').trim())
                    || Number(reward.quantity) > 2147483647,
                )
                if (incompleteReward) {
                    BsMessage.error(`จำนวนของไอเทม ID ${incompleteReward.id} ต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647`)
                    return
                }

                const rewards = this.selectedRewards.map(reward => this.buildReward(reward))
                const params = this.form.emailType === 'allserver'
                    ? {
                        channel: this.selectedEmailChannel,
                        emailType: this.form.emailType,
                        mailId: this.form.mailId.trim(),
                        serverId: this.allServers ? '0' : this.selectedServer,
                        rewards
                    }
                    : {
                        channel: this.selectedEmailChannel,
                        emailType: this.form.emailType,
                        mailId: this.form.mailId.trim(),
                        serverId: 'list',
                        uidList: this.form.uidList.trim(),
                        rewards
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
                this.selectedRewards = [];
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
.email-reward-fields {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
    margin-top: 1rem;
}

.email-reward-picker {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 1rem;
    margin-top: 1rem;
}

.email-reward-type {
    flex: 1 1 240px;
    max-width: 420px;
}

.email-reward-picker-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.5rem;
    padding-bottom: 0.1rem;
}

.email-catalog-list {
    display: grid;
    gap: 0.5rem;
    max-height: 420px;
    overflow-y: auto;
    margin-top: 1rem;
    padding-right: 0.35rem;
}

.email-catalog-item {
    display: grid;
    grid-template-columns: minmax(150px, 0.45fr) minmax(0, 1fr);
    align-items: center;
    gap: 1rem;
    padding: 0.75rem;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    background: var(--bs-tertiary-bg);
}

.email-catalog-choice {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    font-weight: 600;
    cursor: pointer;
}

.email-catalog-choice .form-check-input {
    margin: 0;
}

.email-selected-options {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 0.75rem;
}

.email-selected-options > .email-field {
    width: 120px;
}

.email-advanced-fields {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
}

.email-advanced-fields .email-field {
    width: 130px;
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

.email-template-info {
    display: grid;
    gap: 0.25rem;
    margin-top: 1rem;
    padding: 0.85rem 1rem;
    border-radius: 0.5rem;
    background: var(--bs-tertiary-bg);
    font-size: 0.875rem;
}

.email-template-info span {
    color: var(--bs-secondary-color);
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
    .email-reward-fields {
        grid-template-columns: 1fr;
    }

    .email-section-heading,
    .email-delivery {
        align-items: flex-start;
    }

    .email-catalog-item {
        grid-template-columns: 1fr;
        gap: 0.75rem;
    }
}
</style>
