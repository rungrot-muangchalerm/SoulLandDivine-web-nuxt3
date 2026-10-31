<template>
    <div>
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="message"></i>ส่งอีเมล</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <bs-form ref="form" :model="form" label-width="100px">
                    <bs-form-item label="ประเภทเทมเพลต">
                        <bs-select v-model="form.emailType" @change="changeEmailType" placeholder="เลือกประเภทเทมเพลต" class="mr10">
                            <bs-option
                                v-for="item in type_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </bs-option>
                        </bs-select>
                    </bs-form-item>
                    <bs-form-item label="รหัสเทมเพลต">
                        <bs-input v-model="form.mailId"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ServerID">
                        {{ form.emailType === 'personalemail' ? 'อีเมลส่วนตัว' : (allServers ? 'ทุกเซิร์ฟเวอร์' : (selectedServer || 'เลือกเซิร์ฟเวอร์ที่ Navbar')) }}
                    </bs-form-item>
                    <bs-form-item v-if="form.emailType === 'allserver'" label="ขอบเขต">
                        <bs-switch v-model="allServers" active-text="ทุกเซิร์ฟเวอร์" inactive-text="เซิร์ฟเวอร์ที่เลือก"></bs-switch>
                    </bs-form-item>
                    <bs-form-item label="UID">
                        <bs-input v-model="form.uidList" :disabled="form.emailType === 'allserver'"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ไอเทม 1">
                        <bs-select v-model="form.rewardType1" :disabled="form.emailType === 'allserver'" placeholder="ประเภท" class="mr10 parameter" @change="changeRewardType">
                            <bs-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </bs-option>
                        </bs-select>
                        <bs-input v-model="form.rewardUid1" :disabled="form.emailType === 'allserver'" placeholder="ID" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardNum1" :disabled="form.emailType === 'allserver'" placeholder="จำนวน" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam11" :disabled="form.emailType === 'allserver'" :placeholder="reward1Params.param11" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam12" :disabled="form.emailType === 'allserver'" :placeholder="reward1Params.param12" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam13" :disabled="form.emailType === 'allserver'" :placeholder="reward1Params.param13" class="parameter"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ไอเทม 2">
                        <bs-select v-model="form.rewardType2" :disabled="form.emailType === 'allserver'" placeholder="ประเภท" class="mr10 parameter" @change="changeRewardType">
                            <bs-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </bs-option>
                        </bs-select>
                        <bs-input v-model="form.rewardUid2" :disabled="form.emailType === 'allserver'" placeholder="ID" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardNum2" :disabled="form.emailType === 'allserver'" placeholder="จำนวน" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam21" :disabled="form.emailType === 'allserver'" :placeholder="reward2Params.param21" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam22" :disabled="form.emailType === 'allserver'" :placeholder="reward2Params.param22" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam23" :disabled="form.emailType === 'allserver'" :placeholder="reward2Params.param23" class="parameter"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ไอเทม 3">
                        <bs-select v-model="form.rewardType3" :disabled="form.emailType === 'allserver'" placeholder="ประเภท" class="mr10 parameter" @change="changeRewardType">
                            <bs-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </bs-option>
                        </bs-select>
                        <bs-input v-model="form.rewardUid3" :disabled="form.emailType === 'allserver'" placeholder="ID" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardNum3" :disabled="form.emailType === 'allserver'" placeholder="จำนวน" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam31" :disabled="form.emailType === 'allserver'" :placeholder="reward3Params.param31" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam32" :disabled="form.emailType === 'allserver'" :placeholder="reward3Params.param32" class="parameter"></bs-input>
                        <bs-input v-model="form.rewardParam33" :disabled="form.emailType === 'allserver'" :placeholder="reward3Params.param33" class="parameter"></bs-input>
                    </bs-form-item>
                    <bs-form-item>
                        <bs-button type="primary" @click="handleSendEmail">ส่งอีเมล</bs-button>
                        <bs-button @click="handleCancle">ยกเลิก</bs-button>
                    </bs-form-item>
                </bs-form>
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
                allServers: false,
                type_list: [{
                    value: 'allserver',
                    label: 'อีเมลถึงทุกเซิร์ฟเวอร์'
                }, {
                    value: 'personalemail',
                    label: 'อีเมลส่วนตัว'
                }],
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
                }],
                reward1Params: {
                    param11: 'พารามิเตอร์',
                    param12: 'พารามิเตอร์',
                    param13: 'พารามิเตอร์'
                },
                reward2Params: {
                    param21: 'พารามิเตอร์',
                    param22: 'พารามิเตอร์',
                    param23: 'พารามิเตอร์'
                },
                reward3Params: {
                    param31: 'พารามิเตอร์',
                    param32: 'พารามิเตอร์',
                    param33: 'พารามิเตอร์'
                },
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
        methods: {
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
            // 根据物品类型，改变相应物品参数提示or状态
            changeRewardType () {
                switch (this.form.rewardType1) {
                    case '3':
                        for (const key in this.reward1Params) {
                            this.reward1Params[key] = 'ไม่มี';
                        }
                        this.reward1Params.param11 = 'ปี';
                        break;
                    case '4':
                        this.reward1Params.param11 = 'สัตว์';
                        this.reward1Params.param12 = 'ตำแหน่ง';
                        this.reward1Params.param13 = 'ค่าสถานะหลัก';
                        break;
                    case '':
                        for (const key in this.reward1Params) {
                            this.reward1Params[key] = 'พารามิเตอร์';
                        }
                        break;
                    default:
                        for (const key in this.reward1Params) {
                            this.reward1Params[key] = 'ไม่มี';
                        }
                        break;
                }
                switch (this.form.rewardType2) {
                    case '3':
                        for (const key in this.reward2Params) {
                            this.reward2Params[key] = 'ไม่มี';
                        }
                        this.reward2Params.param21 = 'ปี';
                        break;
                    case '4':
                        this.reward2Params.param21 = 'สัตว์';
                        this.reward2Params.param22 = 'ตำแหน่ง';
                        this.reward2Params.param23 = 'ค่าสถานะหลัก';
                        break;
                    case '':
                        for (const key in this.reward2Params) {
                            this.reward2Params[key] = 'พารามิเตอร์';
                        }
                        break;
                    default:
                        for (const key in this.reward2Params) {
                            this.reward2Params[key] = 'ไม่มี';
                        }
                        break;
                }
                switch (this.form.rewardType3) {
                    case '3':
                        for (const key in this.reward3Params) {
                            this.reward3Params[key] = 'ไม่มี';
                        }
                        this.reward3Params.param31 = 'ปี';
                        break;
                    case '4':
                        this.reward3Params.param31 = 'สัตว์';
                        this.reward3Params.param32 = 'ตำแหน่ง';
                        this.reward3Params.param33 = 'ค่าสถานะหลัก';
                        break;
                    case '':
                        for (const key in this.reward3Params) {
                            this.reward3Params[key] = 'พารามิเตอร์';
                        }
                        break;
                    default:
                        for (const key in this.reward3Params) {
                            this.reward3Params[key] = 'ไม่มี';
                        }
                        break;
                }
            },
            handleSendEmail () {
                let params = null;
                if (this.form.emailType === 'allserver' && this.form.mailId !== "" && (this.selectedServer || this.allServers)) {
                    params = {
                        channel: getCookie('channel'),
                        mailId: this.form.mailId,
                        serverId: this.allServers ? '0' : this.selectedServer
                    }
                } else if (this.form.emailType === 'personalemail' && this.form.mailId !== "" && this.form.uidList !== "") {
                    params = {
                        channel: getCookie('channel'),
                        mailId: this.form.mailId,
                        serverId: 'list',
                        uidList: this.form.uidList,
                        reward1: this.form.rewardUid1
                                + (this.form.rewardType1 ? (':' + this.form.rewardType1) : '')
                                + (this.form.rewardNum1 ? (':' + this.form.rewardNum1) : '')
                                + (this.form.rewardParam11 ? ('@' + this.form.rewardParam11) : '')
                                + (this.form.rewardParam12 ? (':' + this.form.rewardParam12) : '')
                                + (this.form.rewardParam13 ? (':' + this.form.rewardParam13) : '')
                                + (this.form.rewardParam14 ? (':' + this.form.rewardParam14) : '')
                                + (this.form.rewardParam15 ? (':' + this.form.rewardParam15) : '')
                                + (this.form.rewardParam16 ? (':' + this.form.rewardParam16) : ''),
                        reward2: this.form.rewardUid2
                                + (this.form.rewardType2 ? (':' + this.form.rewardType2) : '')
                                + (this.form.rewardNum2 ? (':' + this.form.rewardNum2) : '')
                                + (this.form.rewardParam21 ? ('@' + this.form.rewardParam21) : '')
                                + (this.form.rewardParam22 ? (':' + this.form.rewardParam22) : '')
                                + (this.form.rewardParam23 ? (':' + this.form.rewardParam23) : '')
                                + (this.form.rewardParam24 ? (':' + this.form.rewardParam24) : '')
                                + (this.form.rewardParam25 ? (':' + this.form.rewardParam25) : '')
                                + (this.form.rewardParam26 ? (':' + this.form.rewardParam26) : ''),
                        reward3: this.form.rewardUid3
                                + (this.form.rewardType3 ? (':' + this.form.rewardType3) : '')
                                + (this.form.rewardNum3 ? (':' + this.form.rewardNum3) : '')
                                + (this.form.rewardParam31 ? ('@' + this.form.rewardParam31) : '')
                                + (this.form.rewardParam32 ? (':' + this.form.rewardParam32) : '')
                                + (this.form.rewardParam33 ? (':' + this.form.rewardParam33) : '')
                                + (this.form.rewardParam34 ? (':' + this.form.rewardParam34) : '')
                                + (this.form.rewardParam35 ? (':' + this.form.rewardParam35) : '')
                                + (this.form.rewardParam36 ? (':' + this.form.rewardParam36) : '')
                    }
                };
                if (params !== null) {
                    this.$api.post('/api/email/send',params).then((res)=> {
                        res = res.data;
                        if(JSON.parse(res).result === 1){
                            BsMessage.success('ส่งอีเมลแล้ว!')
                            this.allServers = false;
                            for (const key in this.form) {
                                this.form[key] = '';
                            }
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:'+err)
                    })
                } else {
                    BsMessage.error('กรุณากรอกเนื้อหาอีเมลให้ถูกต้อง');
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
