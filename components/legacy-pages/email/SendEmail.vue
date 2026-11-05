<template>
    <div class="email-page">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="message"></i>ส่งอีเมล</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container email-form-container">
            <section class="email-section email-details-section">
                <div class="email-section-heading email-details-heading">
                    <h2 class="email-section-title">ข้อมูลอีเมล</h2>
                    <div class="email-details-actions">
                        <label class="email-remember-setting" title="บันทึกข้อความและตัวเลือกการส่งไว้ใน localStorage ของเบราว์เซอร์นี้ โดยไม่บันทึก UID หรือของรางวัล">
                            <input v-model="rememberEmailSettings" class="form-check-input" type="checkbox">
                            <span>จำค่าฟอร์ม</span>
                        </label>
                        <button
                            type="button"
                            class="btn btn-sm btn-outline-secondary email-details-toggle"
                            :aria-expanded="!emailDetailsCollapsed"
                            aria-controls="email-details-content"
                            @click="emailDetailsCollapsed = !emailDetailsCollapsed"
                        >
                            {{ emailDetailsCollapsed ? (form.emailType ? 'แก้ไขรายละเอียด' : 'ตั้งค่ารายละเอียด') : 'ย่อรายละเอียด' }}
                            <span aria-hidden="true">{{ emailDetailsCollapsed ? '▸' : '▾' }}</span>
                        </button>
                    </div>
                </div>
                <p v-if="emailDetailsCollapsed" class="email-details-summary">
                    {{ emailDetailsSummary }}
                </p>
                <div id="email-details-content" v-show="!emailDetailsCollapsed" class="email-details-content">
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
                        <span>รูปแบบ / รหัสอีเมล</span>
                        <bs-select v-model="form.mailId" :disabled="emailTemplatesLoading">
                            <bs-option value="" label="เลือกวิธีส่งอีเมล"></bs-option>
                            <bs-option
                                value="1"
                                label="#1 — กำหนดหัวข้อ เนื้อหา และของแนบเอง (Custom)"
                            ></bs-option>
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
                    <span v-if="templateRewardItems.length">
                        รางวัลตั้งต้นของ template แสดงในส่วนของรางวัลแนบด้านล่าง
                    </span>
                    <span v-else>ไม่มีรางวัลตั้งต้น</span>
                    <span v-if="selectedRewards.length">
                        เมื่อเลือกไอเทมด้านล่าง รางวัลที่เลือกจะแทนรางวัลตั้งต้นของ template
                    </span>
                </div>
                <div v-if="customContent" class="email-fields">
                    <label class="email-field">
                        <span>หัวข้ออีเมล</span>
                        <bs-input v-model="form.title" maxlength="255"></bs-input>
                    </label>
                    <label class="email-field">
                        <span>ชื่อผู้ส่ง</span>
                        <input
                            class="form-control"
                            :value="form.senderName"
                            readonly
                            aria-describedby="email-sender-help"
                            placeholder="กำลังโหลดชื่อผู้ใช้..."
                        >
                        <small id="email-sender-help" class="email-help">ใช้ชื่อผู้ใช้ที่เข้าสู่ระบบและแก้ไขไม่ได้</small>
                    </label>
                    <label class="email-field email-content-field">
                        <span>เนื้อหา</span>
                        <textarea
                            v-model="form.content"
                            class="form-control"
                            rows="5"
                            maxlength="2550"
                        ></textarea>
                    </label>
                </div>
                <label v-if="form.emailType === 'personalemail'" class="email-field email-uid-field">
                    <span>ผู้เล่น (serverId:UID)</span>
                    <bs-input v-model="form.uidList" placeholder="เช่น 1001:123456 หรือหลายคนคั่นด้วย |"></bs-input>
                </label>
                </div>
            </section>

            <section class="email-section">
                <div class="email-section-heading">
                    <div>
                        <h2 class="email-section-title">ของรางวัลแนบ</h2>
                        <p class="email-help mb-0">วงแหวนจะส่งแยกฉบับละ 1 วงต่อประเภท จำนวนที่กรอกคือจำนวนฉบับ ส่วนรางวัลชนิดอื่นจะแบ่งอีเมลเมื่อข้อมูลแนบเกิน 255 ตัวอักษร</p>
                    </div>
                </div>
                <div class="email-reward-picker">
                    <label class="email-field email-reward-type">
                        <span>ประเภท</span>
                        <bs-select v-model="selectedRewardType">
                            <bs-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value"
                            ></bs-option>
                        </bs-select>
                    </label>
                    <label v-if="selectedRewardType === '5'" class="email-field email-equipment-quality">
                        <span>คุณภาพอุปกรณ์</span>
                        <bs-select v-model="selectedEquipmentQuality">
                            <bs-option
                                v-for="quality in equipmentQualities"
                                :key="quality.value"
                                :label="quality.label"
                                :value="quality.value"
                            ></bs-option>
                        </bs-select>
                    </label>
                    <label v-if="customContent" class="email-field email-picker-quantity">
                        <span>{{ selectedRewardType === '3' ? 'จำนวนฉบับ' : 'จำนวน' }}</span>
                        <input v-model="manualReward.quantity" class="form-control" type="number" min="1">
                    </label>
                    <label v-if="customContent && selectedRewardType === '3'" class="email-field email-picker-quantity">
                        <span>ปี</span>
                        <input
                            :value="manualReward.year"
                            class="form-control"
                            type="text"
                            inputmode="numeric"
                            placeholder="เช่น 270,145"
                            @input="onManualYearInput"
                        >
                    </label>
                    <button
                        v-if="customContent"
                        type="button"
                        class="btn btn-sm btn-outline-secondary align-self-end"
                        :disabled="!selectedRewards.length"
                        @click="applyQuantityToSelectedRewards"
                    >
                        ใช้จำนวนกับรายการที่เลือก
                    </button>
                    <button
                        v-if="customContent && selectedRewardType === '3'"
                        type="button"
                        class="btn btn-sm btn-outline-secondary align-self-end"
                        :disabled="!selectedRewards.some(reward => reward.rewardType === '3')"
                        @click="applyYearToSelectedSoulRings"
                    >
                        ใช้ปีกับวงแหวนที่เลือก
                    </button>
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
                            :disabled="!selectedRewards.some(reward => reward.rewardType === selectedRewardType)"
                            @click="setCurrentTypeSelection(false)"
                        >
                            ล้างประเภทนี้
                        </button>
                        <span class="badge email-selection-count">เลือกแล้ว {{ selectedRewards.length }} รายการ</span>
                    </div>
                </div>
                <p v-if="customContent && ringEmailCount" class="email-help mt-2 mb-0">
                    วงแหวนที่เลือกจะส่ง {{ ringEmailCount.toLocaleString() }} ฉบับต่อผู้รับ (ฉบับละ 1 วงต่อประเภท)
                </p>
                <p v-if="customContent" class="email-help mt-2 mb-0">
                    เลือกไอเทมจากรายการด้านล่าง แล้วกำหนดจำนวนได้จากช่องด้านบน
                </p>
                <p v-if="selectedRewardType === '5'" class="email-help mt-2 mb-0">
                    เลือกคุณภาพเพื่อกรองรายการอุปกรณ์; อุปกรณ์ที่เลือกจากคุณภาพอื่นยังคงอยู่ในรายการส่ง
                </p>
                <div
                    v-if="!customContent && selectedEmailTemplate && templateRewardItems.length"
                    class="email-template-rewards"
                >
                    <h3 class="email-template-rewards-title">รางวัลจาก Email template</h3>
                    <div class="email-catalog-list email-template-reward-list">
                        <article
                            v-for="item in templateRewardItems"
                            :key="item.key"
                            class="email-catalog-item email-template-reward-card"
                        >
                            <div class="email-catalog-choice">
                                <span class="email-item-media">
                                    <img
                                        v-if="item.iconUrl"
                                        :src="item.iconUrl"
                                        :alt="item.name"
                                        class="email-item-icon"
                                        loading="lazy"
                                        @error="item.iconUrl = null"
                                    >
                                    <span
                                        v-else
                                        class="email-item-icon-placeholder"
                                        aria-label="ไม่มีรูปไอเทม"
                                    >?</span>
                                </span>
                                <span class="email-item-copy">
                                    <span class="email-item-title">{{ item.name }}</span>
                                </span>
                            </div>
                            <div class="email-template-reward-details">
                                <span v-if="item.quantity">จำนวน {{ item.quantity }}</span>
                                <span v-if="item.year">ปี {{ item.year }}</span>
                            </div>
                        </article>
                    </div>
                </div>
                <div v-if="!itemCatalogLoading && !itemCatalogError && itemsForType(selectedRewardType).length" :key="selectedRewardType" class="email-catalog-list">
                    <div
                        v-for="item in itemsForType(selectedRewardType)"
                        :key="`${item.rewardType}:${item.id}`"
                        class="email-catalog-item"
                        :class="{ 'is-selected': isRewardSelected(item) }"
                    >
                        <label class="email-catalog-choice">
                            <input
                                class="form-check-input"
                                type="checkbox"
                                :checked="isRewardSelected(item)"
                                @change="toggleReward(item, $event.target.checked)"
                            >
                            <span class="email-item-media">
                                <img
                                    v-if="item.iconUrl"
                                    :src="item.iconUrl"
                                    :alt="item.name || `ไอเทม ${item.id}`"
                                    class="email-item-icon"
                                    loading="lazy"
                                    @error="item.iconUrl = null"
                                >
                                <span
                                    v-else
                                    class="email-item-icon-placeholder"
                                    :aria-label="`ไม่มีรูปไอเทม ${item.id}`"
                                >?</span>
                            </span>
                            <span class="email-item-copy">
                                <span class="email-item-title">{{ item.name || `ID ${item.id}` }}</span>
                            </span>
                        </label>
                        <div v-if="selectedReward(item)" class="email-selected-options">
                            <label class="email-field email-quantity-field">
                                <span>{{ item.rewardType === '3' ? 'จำนวนฉบับ' : 'จำนวน' }}</span>
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
                                        v-if="item.rewardType === '3' && param.index === 0"
                                        :value="selectedReward(item).params[param.index]"
                                        class="form-control form-control-sm"
                                        type="text"
                                        inputmode="numeric"
                                        :placeholder="param.label"
                                        @input="onSoulRingYearInput(item, $event)"
                                    >
                                    <input
                                        v-else
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
            <div v-if="sending && sendProgress" class="email-help mt-2" role="status">
                {{ sendProgress }}
            </div>
        </div>
    </div>
</template>

<script>
    import itemNames from '~/data/item-names-th.json'
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
import { BsMessage } from '~/utils/bootstrap-message'

    const MAX_SOUL_RING_YEAR = 2147483647
const DEFAULT_EMAIL_TITLE = 'แจ้งชดเชยปัญหาการเข้าเกม'
const DEFAULT_EMAIL_CONTENT = 'ขออภัยในความไม่สะดวก ทีมงานได้ส่งของชดเชยมาให้ กรุณาตรวจสอบของรางวัลแนบ'

    function getThaiItemName(id) {
        const name = itemNames[id]
        return typeof name === 'string' && /[\u0E00-\u0E7F]/.test(name) ? name : undefined
    }

    export default {
        
        setup () { return { words: createAdminWords(), selectedServer: useCookie('selectedServer', { default: () => '' }) } },
        data () {
            return {
                disabled: false,
                sending: false,
                allServers: false,
                emailDetailsCollapsed: true,
                rememberEmailSettings: false,
                isRestoringEmailSettings: false,
                selectedRewardType: '2',
                selectedEquipmentQuality: '',
                selectedRewards: [],
                equipmentQualities: [
                    { value: '', label: 'ทุกคุณภาพ' },
                    { value: '1', label: 'คุณภาพ 1 (ขาว)' },
                    { value: '2', label: 'คุณภาพ 2 (น้ำเงิน)' },
                    { value: '3', label: 'คุณภาพ 3 (ม่วง)' },
                    { value: '4', label: 'คุณภาพ 4 (ส้ม)' },
                    { value: '5', label: 'คุณภาพ 5 (แดง)' },
                    { value: '6', label: 'คุณภาพ 6 (ทอง)' },
                    { value: '7', label: 'คุณภาพ 7 (ตำนาน)' },
                    { value: '8', label: 'คุณภาพ 8 (มหากาพย์)' },
                    { value: '9', label: 'คุณภาพ 9 (มายา)' }
                ],
                manualReward: {
                    quantity: '1',
                    year: ''
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
                    mailId: '1',
                    uidList: '',
                    title: DEFAULT_EMAIL_TITLE,
                    senderName: '',
                    content: DEFAULT_EMAIL_CONTENT
                },
                sendProgress: ''
            }
        },
        mounted () {
            this.loadRememberedEmailSettings()
            this.loadSenderName()
            this.loadItemCatalog()
            this.loadEmailTemplates()
            this.loadEmailChannels()
        },
        watch: {
            emailSettingsToRemember: {
                deep: true,
                handler () {
                    if (this.rememberEmailSettings && !this.isRestoringEmailSettings) {
                        this.saveRememberedEmailSettings()
                    }
                }
            },
            rememberEmailSettings (enabled) {
                if (this.isRestoringEmailSettings) return
                if (enabled) {
                    this.saveRememberedEmailSettings()
                } else {
                    this.removeRememberedEmailSettings()
                }
            }
        },
        computed: {
            customContent () {
                return this.form.mailId === '1'
            },
            emailSettingsToRemember () {
                return {
                    emailType: this.form.emailType,
                    mailId: this.form.mailId,
                    selectedEmailChannel: this.selectedEmailChannel,
                    allServers: this.allServers,
                    title: this.form.title,
                    content: this.form.content
                }
            },
            selectedEmailTemplate () {
                return this.emailTemplates.find(template => String(template.id) === this.form.mailId)
            },
            emailDetailsSummary () {
                if (!this.form.emailType) {
                    return 'กำหนดประเภทอีเมล ช่องทาง และผู้รับก่อนส่ง'
                }

                const summary = [
                    this.type_list.find(item => item.value === this.form.emailType)?.label,
                    this.emailChannels.find(channel => channel.index === this.selectedEmailChannel)?.name,
                    this.form.emailType === 'allserver'
                        ? this.allServers
                            ? 'ทุกเซิร์ฟเวอร์ในช่องทาง'
                            : `เซิร์ฟเวอร์ ${this.selectedServer || 'ยังไม่ได้เลือก'}`
                        : this.form.emailType === 'personalemail'
                            ? `${this.form.uidList.trim() || 'ยังไม่ได้ระบุผู้เล่น'}`
                            : '',
                    this.customContent
                        ? this.form.title.trim() || 'Custom'
                        : this.selectedEmailTemplate?.title || (this.form.mailId ? `Template #${this.form.mailId}` : '')
                ].filter(Boolean)

                return summary.length ? summary.join(' · ') : 'ยังไม่ได้ตั้งค่ารายละเอียดอีเมล'
            },
            templateRewardItems () {
                if (!this.selectedEmailTemplate?.reward) return []

                return this.selectedEmailTemplate.reward.split('|').map((entry, index) => {
                    const [itemPart, parameterPart] = entry.trim().split('@', 2)
                    const match = /^(\d+):(\d+):(\d+)$/.exec(itemPart.trim())
                    if (!match) {
                        return {
                            key: `template:${index}:${entry}`,
                            name: entry.trim(),
                            iconUrl: null,
                            quantity: '',
                            year: ''
                        }
                    }

                    const [, id, rewardType, quantity] = match
                    const item = this.itemCatalog.find(candidate =>
                        candidate.id === id && candidate.rewardType === rewardType
                    )
                    const parameters = (parameterPart || '').split(':')
                    return {
                        key: `template:${rewardType}:${id}:${index}`,
                        name: item?.name || getThaiItemName(id) || `ID ${id}`,
                        iconUrl: item?.iconUrl || null,
                        quantity,
                        year: rewardType === '3' ? parameters[0] || '' : ''
                    }
                })
            },
            ringEmailCount () {
                return this.selectedRewards.reduce((total, reward) => {
                    if (reward.rewardType !== '3') return total
                    const quantity = Number(String(reward.quantity ?? '').trim())
                    return Number.isSafeInteger(quantity) && quantity > 0 ? total + quantity : total
                }, 0)
            }
        },
        methods: {
            loadRememberedEmailSettings () {
                try {
                    const saved = window.localStorage.getItem('email-page-settings-v1')
                    if (!saved) return

                    const parsed = JSON.parse(saved)
                    const settings = parsed?.settings
                    if (
                        parsed?.version !== 1
                        || !settings
                        || typeof settings.emailType !== 'string'
                        || typeof settings.mailId !== 'string'
                        || !['string', 'number'].includes(typeof settings.selectedEmailChannel)
                        || typeof settings.allServers !== 'boolean'
                        || typeof settings.title !== 'string'
                        || typeof settings.content !== 'string'
                    ) {
                        throw new Error('ข้อมูลการตั้งค่าที่บันทึกไว้ไม่ถูกต้อง')
                    }

                    this.isRestoringEmailSettings = true
                    this.form.emailType = settings.emailType
                    this.form.mailId = settings.mailId
                    this.selectedEmailChannel = String(settings.selectedEmailChannel)
                    this.allServers = settings.allServers
                    this.form.title = settings.title
                    this.form.content = settings.content
                    this.rememberEmailSettings = true
                    this.isRestoringEmailSettings = false
                } catch (error) {
                    this.isRestoringEmailSettings = false
                    BsMessage.error(error instanceof Error
                        ? `โหลดการตั้งค่าที่จำไว้ไม่สำเร็จ: ${error.message}`
                        : 'โหลดการตั้งค่าที่จำไว้ไม่สำเร็จ')
                }
            },
            saveRememberedEmailSettings () {
                try {
                    window.localStorage.setItem('email-page-settings-v1', JSON.stringify({
                        version: 1,
                        settings: this.emailSettingsToRemember
                    }))
                } catch (error) {
                    BsMessage.error(error instanceof Error
                        ? `บันทึกการตั้งค่าไม่สำเร็จ: ${error.message}`
                        : 'บันทึกการตั้งค่าไม่สำเร็จ')
                }
            },
            removeRememberedEmailSettings () {
                try {
                    window.localStorage.removeItem('email-page-settings-v1')
                } catch (error) {
                    BsMessage.error(error instanceof Error
                        ? `ลบการตั้งค่าที่จำไว้ไม่สำเร็จ: ${error.message}`
                        : 'ลบการตั้งค่าที่จำไว้ไม่สำเร็จ')
                }
            },
            async loadSenderName () {
                try {
                    const response = await this.$api.get('/api/session')
                    this.form.senderName = response.data.username
                } catch (error) {
                    BsMessage.error(error instanceof Error ? error.message : 'โหลดชื่อผู้ใช้ไม่สำเร็จ')
                }
            },
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
                    this.emailTemplates = response.data.filter(template => Number(template.id) !== 1)
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
                return this.itemCatalog.filter(item =>
                    item.rewardType === rewardType
                    && (
                        rewardType !== '5'
                        || !this.selectedEquipmentQuality
                        || String(item.quality) === this.selectedEquipmentQuality
                    )
                )
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
                if (!checked) {
                    this.selectedRewards = this.selectedRewards.filter(
                        reward => reward.rewardType !== this.selectedRewardType
                    )
                    return
                }

                const unselectedItems = this.itemsForType(this.selectedRewardType)
                    .filter(item => !this.isRewardSelected(item))
                for (const item of unselectedItems) {
                    this.toggleReward(item, true)
                }
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
            applyYearToSelectedSoulRings () {
                const year = String(this.manualReward.year).replaceAll(',', '').trim()
                if (!/^[1-9]\d*$/.test(year) || Number(year) > MAX_SOUL_RING_YEAR) {
                    BsMessage.error(`ปีวงแหวนวิญญาณต้องเป็นจำนวนเต็มระหว่าง 1 ถึง ${MAX_SOUL_RING_YEAR}`)
                    return
                }
                const selectedSoulRings = this.selectedRewards.filter(reward => reward.rewardType === '3')
                if (!selectedSoulRings.length) {
                    BsMessage.error('กรุณาเลือกวงแหวนวิญญาณก่อน')
                    return
                }
                for (const reward of selectedSoulRings) {
                    reward.params[0] = year
                }
                BsMessage.success(`กำหนดอายุ ${year} ปีให้วงแหวนที่เลือก ${selectedSoulRings.length} รายการแล้ว`)
            },
            formatYearInput (event, updateValue) {
                const input = event.target
                const selectionStart = input.selectionStart ?? input.value.length
                const digitsBeforeCursor = input.value.slice(0, selectionStart).replace(/\D/g, '').length
                const digits = input.value.replace(/\D/g, '')
                const formatted = digits.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
                updateValue(formatted)

                this.$nextTick(() => {
                    let cursor = 0
                    let digitsAtCursor = 0
                    while (cursor < formatted.length && digitsAtCursor < digitsBeforeCursor) {
                        if (/\d/.test(formatted[cursor])) digitsAtCursor++
                        cursor++
                    }
                    input.setSelectionRange(cursor, cursor)
                })
            },
            onManualYearInput (event) {
                this.formatYearInput(event, value => {
                    this.manualReward.year = value
                })
            },
            onSoulRingYearInput (item, event) {
                this.formatYearInput(event, value => {
                    this.selectedReward(item).params[0] = value
                })
            },
            changeEmailType () {
                this.allServers = false;
                this.form.mailId = '1';
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
                return reward + '@' + params.slice(firstParam, lastParam + 1).map((param, index) => {
                    const value = param || ''
                    return rewardItem.rewardType === '3' && firstParam + index === 0
                        ? value.replaceAll(',', '')
                        : value
                }).join(':')
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
                if (incompleteReward) {
                    BsMessage.error(`จำนวนของไอเทม ID ${incompleteReward.id} ต้องเป็นจำนวนเต็มบวกไม่เกิน 2147483647`)
                    return
                }
                const incompleteSoulRing = this.selectedRewards.find((reward) => {
                    if (reward.rewardType !== '3') return false
                    const year = String(reward.params[0] || '').replaceAll(',', '')
                    return !/^[1-9]\d*$/.test(year) || Number(year) > MAX_SOUL_RING_YEAR
                })
                if (incompleteSoulRing) {
                    this.selectedRewardType = '3'
                    BsMessage.error(`ปีวงแหวนวิญญาณ ID ${incompleteSoulRing.id} ต้องเป็นจำนวนเต็มระหว่าง 1 ถึง ${MAX_SOUL_RING_YEAR}`)
                    return
                }
                if (this.customContent && this.ringEmailCount > 0) {
                    const recipientCount = this.form.emailType === 'personalemail'
                        ? this.form.uidList.split('|').filter(entry => entry.trim()).length
                        : 1
                    const totalRingEmails = this.ringEmailCount * recipientCount
                    const destination = this.form.emailType === 'allserver'
                        ? 'ต่อผู้เล่นในเซิร์ฟเวอร์ปลายทาง'
                        : `${totalRingEmails.toLocaleString()} ฉบับรวมทุกผู้รับ`
                    if (!window.confirm(`วงแหวนจะถูกส่งแยกฉบับละ 1 วงต่อประเภท จำนวน ${this.ringEmailCount.toLocaleString()} ฉบับต่อผู้รับ (${destination}) ยืนยันส่งหรือไม่?`)) {
                        return
                    }
                }

                const rewards = this.selectedRewards.map(reward => this.buildReward(reward))
                const params = this.form.emailType === 'allserver'
                    ? this.customContent
                        ? {
                            channel: this.selectedEmailChannel,
                            emailType: this.form.emailType,
                            serverId: this.allServers ? '0' : this.selectedServer,
                            title: this.form.title.trim(),
                            senderName: this.form.senderName.trim(),
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
                            senderName: this.form.senderName.trim(),
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
                this.sendProgress = 'รับคำขอแล้ว กำลังเข้าคิวส่งอีเมล...'
                try {
                    const endpoint = this.customContent
                        ? '/api/email/sendCustom'
                        : '/api/email/send'
                    const response = await this.$api.post(endpoint, params)
                    const result = typeof response.data === 'string'
                        ? JSON.parse(response.data)
                        : response.data
                    if (this.customContent && result?.queued && typeof result.jobId === 'string') {
                        const job = await this.waitForEmailJob(result.jobId)
                        if (job.status === 'failed') {
                            throw new Error(job.error || 'งานส่งอีเมลหยุดทำงาน')
                        }
                        if (job.result === 1) {
                            BsMessage.success(`ส่งอีเมลสำเร็จ ${job.sent.toLocaleString()}/${job.total.toLocaleString()} ฉบับ`)
                            this.handleCancle(true)
                        } else {
                            const failedSamples = Array.isArray(job.failures)
                                ? job.failures.map(item => `${item.recipient}: ${item.message}`).join('\n')
                                : ''
                            BsMessage.error([
                                `ส่งสำเร็จ ${job.sent.toLocaleString()}/${job.total.toLocaleString()} ฉบับ; ล้มเหลว ${job.failedCount.toLocaleString()} ฉบับ`,
                                failedSamples ? `ตัวอย่างรายการที่ไม่สำเร็จ:\n${failedSamples}` : ''
                            ].filter(Boolean).join('\n'))
                        }
                        return
                    }
                    if (result?.result === 1) {
                        if (this.customContent && result.batchCount > 1) {
                            BsMessage.success(`ส่งอีเมล ${result.batchCount} ชุดไปยัง ${result.targetCount} ${this.form.emailType === 'allserver' ? 'เซิร์ฟเวอร์' : 'ผู้เล่น'}สำเร็จ`)
                        } else if (result.batchCount > 1) {
                            BsMessage.success(`ส่งอีเมลสำเร็จ ${result.sent.toLocaleString()}/${result.total.toLocaleString()} ชุด`)
                        } else {
                            BsMessage.success(result.sent < result.total
                                ? `ส่งสำเร็จ ${result.sent}/${result.total} ${this.form.emailType === 'allserver' ? 'เซิร์ฟเวอร์' : 'รายการ'}`
                                : 'ส่งอีเมลสำเร็จ')
                        }
                        this.handleCancle(true)
                    } else {
                        const partialMessage = Number.isInteger(result?.sent) && Number.isInteger(result?.total)
                            ? (
                                this.customContent && result.batchCount > 1
                                    ? `ส่งสำเร็จ ${result.sent}/${result.total} ฉบับอีเมล`
                                    : result.batchCount > 1
                                        ? `ส่งอีเมลสำเร็จ ${result.sent}/${result.total} ชุด`
                                        : `ส่งสำเร็จ ${result.sent}/${result.total} ${this.form.emailType === 'allserver' ? 'เซิร์ฟเวอร์' : 'รายการ'}`
                            )
                            : ''
                        const failedRecipients = Array.isArray(result?.failed)
                            ? result.failed.map(item => item.recipient).join(', ')
                            : ''
                        BsMessage.error([
                            partialMessage || result?.message || 'ส่งอีเมลไม่สำเร็จ กรุณาตรวจสอบข้อมูลและลองอีกครั้ง',
                            Array.isArray(result?.failedBatches) && result.failedBatches.length
                                ? `ชุดที่ไม่สำเร็จ: ${result.failedBatches.join(', ')}`
                                : '',
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
                    this.sendProgress = ''
                }
            },
            async waitForEmailJob (jobId) {
                while (true) {
                    await new Promise(resolve => window.setTimeout(resolve, 1000))
                    const response = await this.$api.get(`/api/email/custom-jobs/${encodeURIComponent(jobId)}`)
                    const job = typeof response.data === 'string'
                        ? JSON.parse(response.data)
                        : response.data
                    if (!job || !['queued', 'processing', 'completed', 'failed'].includes(job.status)) {
                        throw new Error('ไม่สามารถอ่านสถานะงานส่งอีเมลได้')
                    }
                    this.sendProgress = job.status === 'queued'
                        ? 'อีเมลอยู่ในคิว รอเริ่มส่ง...'
                        : `กำลังส่งอีเมล ${Number(job.processed || 0).toLocaleString()}/${Number(job.total || 0).toLocaleString()} ฉบับ`
                    if (job.status === 'completed' || job.status === 'failed') return job
                }
            },
            handleCancle (preserveRememberedSettings = false) {
                const emailType = this.form.emailType;
                const mailId = this.form.mailId;
                const senderName = this.form.senderName;
                const title = preserveRememberedSettings && this.rememberEmailSettings
                    ? this.form.title
                    : DEFAULT_EMAIL_TITLE
                const content = preserveRememberedSettings && this.rememberEmailSettings
                    ? this.form.content
                    : DEFAULT_EMAIL_CONTENT
                const allServers = preserveRememberedSettings && this.rememberEmailSettings
                    ? this.allServers
                    : false
                this.allServers = false;
                this.selectedRewards = [];
                this.manualReward.quantity = '1';
                this.manualReward.year = '';
                for (const key in this.form) {
                    this.form[key] = '';
                }
                this.form.emailType = emailType;
                this.form.mailId = mailId;
                this.form.title = title
                this.form.content = content
                this.form.senderName = senderName
                this.allServers = allServers
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

.email-details-heading {
    margin-bottom: 0.9rem;
}

.email-details-actions {
    display: flex;
    align-items: center;
    gap: 0.8rem;
}

.email-remember-setting {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    margin: 0;
    color: var(--bs-secondary-color);
    font-size: 0.8rem;
    font-weight: 500;
    white-space: nowrap;
    cursor: pointer;
}

.email-remember-setting .form-check-input {
    margin: 0;
}

.email-details-toggle {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    white-space: nowrap;
}

.email-details-summary {
    margin: 0;
    overflow: hidden;
    color: var(--bs-secondary-color);
    font-size: 0.875rem;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.email-details-content {
    display: grid;
    gap: 1rem;
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
    flex: 0 1 190px;
    max-width: 220px;
}

.email-equipment-quality {
    flex: 0 1 190px;
    max-width: 220px;
}

.email-picker-quantity {
    flex: 0 1 110px;
}

.email-reward-picker-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.5rem;
    padding-bottom: 0.1rem;
}

.email-template-rewards {
    margin-top: 1rem;
}

.email-template-rewards-title {
    margin: 0;
    color: var(--bs-secondary-color);
    font-size: 0.85rem;
    font-weight: 650;
}

.email-template-reward-list {
    max-height: 260px;
    margin-top: 0.65rem;
}

.email-template-reward-card {
    min-height: 0;
    cursor: default;
}

.email-template-reward-details {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.35rem 0.75rem;
    color: var(--bs-secondary-color);
    font-size: 0.8rem;
}

.email-selection-count {
    color: #e2e3e5;
    background-color: #55595f;
    font-weight: 600;
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
    grid-template-columns: repeat(auto-fill, minmax(min(100%, 220px), 1fr));
    gap: 0.75rem;
    max-height: 420px;
    overflow-y: auto;
    margin-top: 1rem;
    padding: 0.1rem 0.35rem 0.25rem 0.1rem;
}

.email-catalog-item {
    position: relative;
    display: grid;
    align-content: start;
    gap: 0.7rem;
    min-width: 0;
    min-height: 196px;
    padding: 1rem 0.85rem 0.85rem;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.75rem;
    background: var(--admin-surface, var(--bs-tertiary-bg));
    transition: border-color 140ms ease, background-color 140ms ease, box-shadow 140ms ease;
}

.email-catalog-item:hover {
    border-color: color-mix(in srgb, var(--admin-accent, var(--bs-primary)) 55%, var(--bs-border-color));
    background: color-mix(in srgb, var(--admin-accent, var(--bs-primary)) 5%, var(--admin-surface, var(--bs-tertiary-bg)));
}

.email-catalog-item.is-selected {
    border-color: var(--admin-accent, var(--bs-primary));
    background: color-mix(in srgb, var(--admin-accent, var(--bs-primary)) 9%, var(--admin-surface, var(--bs-tertiary-bg)));
    box-shadow: inset 0 0 0 1px color-mix(in srgb, var(--admin-accent, var(--bs-primary)) 25%, transparent);
}

.email-catalog-choice {
    display: grid;
    justify-items: center;
    gap: 0.65rem;
    min-width: 0;
    margin: 0;
    padding: 0.15rem 0 0.1rem;
    text-align: center;
    cursor: pointer;
}

.email-catalog-choice .form-check-input {
    position: absolute;
    top: 0.7rem;
    right: 0.7rem;
    z-index: 1;
    width: 1rem;
    height: 1rem;
    margin: 0;
}

.email-item-media {
    display: grid;
    width: 88px;
    height: 88px;
    place-items: center;
}

.email-item-copy {
    display: grid;
    min-width: 0;
    gap: 0.15rem;
    align-content: start;
    justify-items: center;
}

.email-item-title {
    max-width: 100%;
    overflow-wrap: anywhere;
    font-weight: 650;
    line-height: 1.35;
}

.email-item-icon,
.email-item-icon-placeholder {
    width: 80px;
    height: 80px;
    border: 1px solid color-mix(in srgb, var(--admin-accent, var(--bs-primary)) 22%, var(--bs-border-color));
    border-radius: 0.75rem;
    background: color-mix(in srgb, var(--admin-accent, var(--bs-primary)) 7%, var(--bs-body-bg));
}

.email-item-icon {
    border: 0;
    background: transparent;
    object-fit: contain;
    padding: 0.3rem;
}

.email-item-icon-placeholder {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    color: var(--bs-secondary-color);
    font-weight: 600;
}

.email-selected-options {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(90px, 1fr));
    align-items: end;
    gap: 0.55rem;
    padding-top: 0.7rem;
    border-top: 1px solid var(--bs-border-color);
}

.email-selected-options > .email-field {
    width: auto;
    font-size: 0.8rem;
}

.email-advanced-fields {
    display: contents;
}

.email-advanced-fields .email-field {
    width: auto;
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

    .email-details-heading {
        align-items: center;
    }

    .email-details-actions {
        gap: 0.5rem;
    }

    .email-catalog-list {
        grid-template-columns: repeat(auto-fill, minmax(min(100%, 170px), 1fr));
    }
}
</style>
