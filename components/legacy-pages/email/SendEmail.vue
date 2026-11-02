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
                    <label v-if="!customContent" class="email-field">
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
                <label class="email-custom-toggle">
                    <input v-model="customContent" class="form-check-input" type="checkbox">
                    <span>กำหนดหัวข้อ เนื้อหา และของแนบเอง (Custom)</span>
                </label>
                <div v-if="form.emailType === 'allserver'" class="email-delivery">
                    <div class="email-delivery-copy">
                        <strong>ผู้รับ</strong>
                        <span>{{ allServers ? 'ส่งถึงผู้เล่นทุกเซิร์ฟเวอร์ในช่องทาง' : `ส่งถึงผู้เล่นทั้งเซิร์ฟเวอร์ ${selectedServer || 'ที่เลือกในแถบด้านบน'}` }}</span>
                    </div>
                    <bs-switch
                        v-model="allServers"
                        active-text="ทุกเซิร์ฟเวอร์ในช่องทาง"
                        inactive-text="เซิร์ฟเวอร์ที่เลือก"
                    ></bs-switch>
                </div>
                <div v-if="!customContent && selectedEmailTemplate" class="email-template-info">
                    <strong>{{ selectedEmailTemplate.title || `Email template #${selectedEmailTemplate.id}` }}</strong>
                    <span v-if="selectedEmailTemplate.reward">
                        มีรางวัลตั้งต้น: {{ selectedEmailTemplate.reward }}
                    </span>
                    <span v-else>ไม่มีรางวัลตั้งต้น</span>
                    <span v-if="selectedRewards.length">
                        เมื่อเลือกไอเทมด้านล่าง รางวัลที่เลือกจะแทนรางวัลตั้งต้นของ template
                    </span>
                </div>
                <div v-if="customContent" class="email-fields">
                    <label class="email-field">
                        <span>หัวข้ออีเมล</span>
                        <bs-input v-model="form.title" maxlength="255" placeholder="กรอกหัวข้ออีเมล"></bs-input>
                    </label>
                    <label class="email-field">
                        <span>ชื่อผู้ส่ง</span>
                        <bs-input v-model="form.senderName" maxlength="255" placeholder="เช่น GM"></bs-input>
                    </label>
                    <label class="email-field email-content-field">
                        <span>เนื้อหา</span>
                        <textarea
                            v-model="form.content"
                            class="form-control"
                            rows="5"
                            maxlength="2550"
                            placeholder="กรอกเนื้อหาอีเมล"
                        ></textarea>
                    </label>
                </div>
                <label v-if="form.emailType === 'personalemail'" class="email-field email-uid-field">
                    <span>ผู้เล่น (serverId:UID)</span>
                    <bs-input v-model="form.uidList" placeholder="เช่น 1001:123456 หรือหลายคนคั่นด้วย |"></bs-input>
                </label>
            </section>

            <section class="email-section">
                <div class="email-section-heading">
                    <div>
                        <h2 class="email-section-title">ของรางวัลแนบ</h2>
                        <p class="email-help mb-0">เลือกของแนบได้สูงสุด 255 รายการ ระบบจะแบ่งอีเมลเมื่อข้อมูลของแนบรวมเกิน 255 ตัวอักษรต่อฉบับ</p>
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
                <div v-if="customContent" class="email-manual-reward">
                    <label class="email-field">
                        <span>ประเภทไอเทม</span>
                        <bs-select v-model="manualReward.rewardType">
                            <bs-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value"
                            ></bs-option>
                        </bs-select>
                    </label>
                    <label class="email-field">
                        <span>ID ไอเทม</span>
                        <input v-model="manualReward.id" class="form-control" inputmode="numeric" placeholder="กรอก ID">
                    </label>
                    <label class="email-field">
                        <span>จำนวน</span>
                        <input v-model="manualReward.quantity" class="form-control" type="number" min="1">
                    </label>
                    <button
                        type="button"
                        class="btn btn-outline-secondary align-self-end"
                        :disabled="!selectedRewards.length"
                        @click="applyQuantityToSelectedRewards"
                    >
                        ใช้จำนวนนี้กับรายการที่เลือก
                    </button>
                    <label
                        v-for="param in rewardParameterFields(manualReward.rewardType)"
                        :key="param.index"
                        class="email-field"
                    >
                        <span>{{ param.label }}</span>
                        <input
                            v-model="manualReward.params[param.index]"
                            class="form-control"
                            type="number"
                            min="1"
                            max="2147483647"
                            step="1"
                            inputmode="numeric"
                            :placeholder="param.label"
                        >
                    </label>
                    <button
                        type="button"
                        class="btn btn-outline-primary align-self-end"
                        @click="addManualReward"
                    >
                        เพิ่มไอเทมตาม ID
                    </button>
                </div>
                <p v-if="customContent" class="email-help mt-2 mb-0">
                    เพิ่มไอเทมด้วย ID ได้ แม้ไม่มีในรายการร้านค้า
                </p>
                <div v-if="!itemCatalogLoading && !itemCatalogError && itemsForType(selectedRewardType).length" :key="selectedRewardType" class="email-catalog-list">
                    <div v-for="item in itemsForType(selectedRewardType)" :key="`${item.rewardType}:${item.id}`" class="email-catalog-item">
                        <label class="email-catalog-choice">
                            <input
                                class="form-check-input"
                                type="checkbox"
                                :checked="isRewardSelected(item)"
                                @change="toggleReward(item, $event.target.checked)"
                            >
                            <img
                                v-if="item.iconUrl"
                                :src="item.iconUrl"
                                :alt="`ไอเทม ${item.id}`"
                                class="email-item-icon"
                                loading="lazy"
                                @error="item.iconUrl = null"
                            >
                            <span
                                v-else
                                class="email-item-icon-placeholder"
                                :aria-label="`ไม่มีรูปไอเทม ${item.id}`"
                            >?</span>
                            <span>
                                ID {{ item.id }}
                                <small v-if="item.name" class="email-item-name">{{ item.name }}</small>
                            </span>
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
                                        type="number"
                                        min="1"
                                        max="2147483647"
                                        step="1"
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
                    รูปไอเทมอ้างอิง ID จากไอคอนใน Game Client หากไม่มีไฟล์ภาพจะแสดงเครื่องหมาย ?
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

    const MAX_SOUL_RING_YEAR = 2147483647

    export default {
        
        setup () { return { words: createAdminWords(), selectedServer: useCookie('selectedServer', { default: () => '' }) } },
        data () {
            return {
                disabled: false,
                sending: false,
                allServers: false,
                customContent: false,
                selectedRewardType: '2',
                selectedRewards: [],
                manualReward: {
                    id: '',
                    rewardType: '2',
                    quantity: '1',
                    params: ['', '', '']
                },
                type_list: [{
                    value: 'allserver',
                    label: 'อีเมลถึงผู้เล่นในเซิร์ฟเวอร์'
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
                    value: '7',
                    label: 'ตัวละคร'
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
                    title: '',
                    senderName: '',
                    content: ''
                }
            }
        },
        mounted () {
            if (!this.form.senderName.trim()) {
                this.form.senderName = getCookie('username')
            }
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
                    if (this.selectedRewards.length >= 255) {
                        BsMessage.error('เลือกของแนบได้สูงสุด 255 รายการ')
                        return
                    }
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
                if (!checked) {
                    this.selectedRewards = this.selectedRewards.filter(
                        reward => reward.rewardType !== this.selectedRewardType
                    )
                    return
                }

                const availableSlots = 255 - this.selectedRewards.length
                if (availableSlots <= 0) {
                    BsMessage.error('เลือกของแนบได้สูงสุด 255 รายการ')
                    return
                }

                const unselectedItems = this.itemsForType(this.selectedRewardType)
                    .filter(item => !this.isRewardSelected(item))
                for (const item of unselectedItems.slice(0, availableSlots)) {
                    this.toggleReward(item, true)
                }
                if (unselectedItems.length > availableSlots) {
                    BsMessage.error('เลือกของแนบได้สูงสุด 255 รายการ เลือกเพิ่มได้เท่าที่เหลือ')
                }
            },
            addManualReward () {
                const id = String(this.manualReward.id).trim()
                const quantity = String(this.manualReward.quantity).trim()
                if (!/^[1-9]\d*$/.test(id) || Number(id) > 2147483647) {
                    BsMessage.error('ID ไอเทมต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647')
                    return
                }
                if (!/^[1-9]\d*$/.test(quantity) || Number(quantity) > 2147483647) {
                    BsMessage.error('จำนวนไอเทมต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647')
                    return
                }
                if (this.manualReward.params.some(param => param && !/^\d+$/.test(param))) {
                    BsMessage.error('พารามิเตอร์ไอเทมต้องเป็นตัวเลข')
                    return
                }
                if (this.manualReward.rewardType === '3'
                    && (!/^[1-9]\d*$/.test(this.manualReward.params[0])
                        || Number(this.manualReward.params[0]) > MAX_SOUL_RING_YEAR)) {
                    BsMessage.error(`ปีวงแหวนวิญญาณต้องเป็นจำนวนเต็มระหว่าง 1 ถึง ${MAX_SOUL_RING_YEAR}`)
                    return
                }

                const item = { id, rewardType: this.manualReward.rewardType }
                if (this.isRewardSelected(item)) {
                    BsMessage.error('ไอเทมนี้อยู่ในรายการของรางวัลแล้ว')
                    return
                }
                if (this.selectedRewards.length >= 255) {
                    BsMessage.error('เลือกของแนบได้สูงสุด 255 รายการ')
                    return
                }
                this.selectedRewards.push({
                    key: this.rewardKey(item),
                    id,
                    rewardType: item.rewardType,
                    quantity,
                    params: [...this.manualReward.params]
                })
                this.manualReward.id = ''
                this.manualReward.quantity = '1'
                this.manualReward.params = ['', '', '']
            },
            applyQuantityToSelectedRewards () {
                const quantity = String(this.manualReward.quantity).trim()
                if (!/^[1-9]\d*$/.test(quantity) || Number(quantity) > 2147483647) {
                    BsMessage.error('จำนวนไอเทมต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647')
                    return
                }
                for (const reward of this.selectedRewards) {
                    reward.quantity = quantity
                }
                BsMessage.success(`กำหนดจำนวน ${quantity} ให้ไอเทมที่เลือก ${this.selectedRewards.length} รายการแล้ว`)
            },
            changeEmailType () {
                this.allServers = false;
                this.form.mailId = '';
                this.form.uidList = '';
            },
            buildReward (rewardItem) {
                const reward = `${rewardItem.id}:${rewardItem.rewardType}:${String(rewardItem.quantity ?? '').trim()}`
                const params = rewardItem.params;
                const firstParam = params.findIndex(param => param);
                if (firstParam === -1) return reward
                let lastParam = params.length - 1
                while (lastParam > firstParam && !params[lastParam]) {
                    lastParam--
                }
                return reward + '@' + params.slice(firstParam, lastParam + 1).map(param => param || '').join(':')
            },
            async handleSendEmail () {
                if (!this.form.emailType) {
                    BsMessage.error('กรุณาเลือกประเภทอีเมล')
                    return
                }
                if (this.customContent) {
                    if (!this.form.title.trim()) {
                        BsMessage.error('กรุณากรอกหัวข้ออีเมล')
                        return
                    }
                    if (!this.form.content.trim()) {
                        BsMessage.error('กรุณากรอกเนื้อหาอีเมล')
                        return
                    }
                    if (this.form.title.length > 255 || this.form.senderName.trim().length > 255 || this.form.content.length > 2550) {
                        BsMessage.error('หัวข้อ/ชื่อผู้ส่งต้องไม่เกิน 255 ตัวอักษร และเนื้อหาต้องไม่เกิน 2550 ตัวอักษร')
                        return
                    }
                } else {
                    if (!this.form.mailId.trim()) {
                        BsMessage.error('กรุณาเลือก Email template')
                        return
                    }
                    if (!this.emailTemplates.some(template => String(template.id) === this.form.mailId.trim())) {
                        BsMessage.error('Email template ที่เลือกไม่มีอยู่ กรุณาโหลดรายการใหม่')
                        return
                    }
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
                if (this.selectedRewards.length > 255) {
                    BsMessage.error('เลือกของแนบได้สูงสุด 255 รายการ')
                    return
                }
                if (incompleteReward) {
                    BsMessage.error(`จำนวนของไอเทม ID ${incompleteReward.id} ต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647`)
                    return
                }
                const incompleteSoulRing = this.selectedRewards.find(reward =>
                    reward.rewardType === '3'
                    && (!/^[1-9]\d*$/.test(reward.params[0] || '')
                        || Number(reward.params[0]) > MAX_SOUL_RING_YEAR),
                )
                if (incompleteSoulRing) {
                    this.selectedRewardType = '3'
                    BsMessage.error(`ปีวงแหวนวิญญาณ ID ${incompleteSoulRing.id} ต้องเป็นจำนวนเต็มระหว่าง 1 ถึง ${MAX_SOUL_RING_YEAR}`)
                    return
                }

                const rewards = this.selectedRewards.map(reward => this.buildReward(reward))
                const params = this.form.emailType === 'allserver'
                    ? this.customContent
                        ? {
                            channel: this.selectedEmailChannel,
                            emailType: this.form.emailType,
                            serverId: this.allServers ? '0' : this.selectedServer,
                            title: this.form.title.trim(),
                            senderName: this.form.senderName.trim() || getCookie('username'),
                            content: this.form.content,
                            rewards
                        }
                        : {
                            channel: this.selectedEmailChannel,
                            emailType: this.form.emailType,
                            mailId: this.form.mailId.trim(),
                            serverId: this.allServers ? '0' : this.selectedServer,
                            rewards
                        }
                    : this.customContent
                        ? {
                            channel: this.selectedEmailChannel,
                            emailType: this.form.emailType,
                            uidList: this.form.uidList.trim(),
                            title: this.form.title.trim(),
                            senderName: this.form.senderName.trim() || getCookie('username'),
                            content: this.form.content,
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
                    const endpoint = this.customContent
                        ? '/api/email/sendCustom'
                        : '/api/email/send'
                    const response = await this.$api.post(endpoint, params)
                    const result = typeof response.data === 'string'
                        ? JSON.parse(response.data)
                        : response.data
                    if (result?.result === 1) {
                        if (this.customContent && result.batchCount > 1) {
                            BsMessage.success(`ส่งอีเมล ${result.batchCount} ชุดไปยัง ${result.targetCount} ${this.form.emailType === 'allserver' ? 'เซิร์ฟเวอร์' : 'ผู้เล่น'}สำเร็จ`)
                        } else {
                            BsMessage.success(result.sent < result.total
                                ? `ส่งสำเร็จ ${result.sent}/${result.total} ${this.form.emailType === 'allserver' ? 'เซิร์ฟเวอร์' : 'รายการ'}`
                                : 'ส่งอีเมลสำเร็จ')
                        }
                        this.handleCancle()
                    } else {
                        const partialMessage = Number.isInteger(result?.sent) && Number.isInteger(result?.total)
                            ? this.customContent && result.batchCount > 1
                                ? `ส่งสำเร็จ ${result.sent}/${result.total} ฉบับอีเมล`
                                : `ส่งสำเร็จ ${result.sent}/${result.total} ${this.form.emailType === 'allserver' ? 'เซิร์ฟเวอร์' : 'รายการ'}`
                            : ''
                        const failedRecipients = Array.isArray(result?.failed)
                            ? result.failed.map(item => item.recipient).join(', ')
                            : ''
                        BsMessage.error([
                            partialMessage || result?.message || 'ส่งอีเมลไม่สำเร็จ กรุณาตรวจสอบข้อมูลและลองอีกครั้ง',
                            failedRecipients ? `ส่งไม่สำเร็จ: ${failedRecipients}` : ''
                        ].filter(Boolean).join('\n'))
                    }
                } catch (error) {
                    const responseMessage = error && typeof error === 'object'
                        ? error.data?.message || error.response?._data?.message
                            || error.data?.statusMessage || error.response?._data?.statusMessage
                        : ''
                    BsMessage.error(typeof responseMessage === 'string' && responseMessage
                        ? responseMessage
                        : error instanceof Error ? error.message : 'ส่งอีเมลไม่สำเร็จ')
                } finally {
                    this.sending = false
                }
            },
            handleCancle () {
                this.allServers = false;
                this.selectedRewards = [];
                this.manualReward.id = '';
                this.manualReward.rewardType = '2';
                this.manualReward.quantity = '1';
                this.manualReward.params = ['', '', ''];
                for (const key in this.form) {
                    this.form[key] = '';
                }
                this.form.senderName = getCookie('username')
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

.email-content-field {
    grid-column: 1 / -1;
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

.email-manual-reward {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    align-items: end;
    gap: 0.75rem;
    margin-top: 1rem;
    padding: 0.85rem;
    border: 1px dashed var(--bs-border-color);
    border-radius: 0.5rem;
    background: var(--bs-tertiary-bg);
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

.email-item-name {
    display: block;
    color: var(--bs-secondary-color);
    font-weight: 400;
}

.email-item-icon,
.email-item-icon-placeholder {
    width: 40px;
    height: 40px;
    flex: 0 0 40px;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.4rem;
    background: var(--bs-body-bg);
}

.email-item-icon {
    object-fit: contain;
}

.email-item-icon-placeholder {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    color: var(--bs-secondary-color);
    font-weight: 600;
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

.email-custom-toggle {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    margin-top: 1rem;
    font-weight: 600;
    cursor: pointer;
}

.email-custom-toggle .form-check-input {
    margin: 0;
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
