<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-message"></i>ส่งอีเมล</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <el-form ref="form" :model="form" label-width="100px">
                    <el-form-item label="ประเภทเทมเพลต">
                        <el-select v-model="form.emailType" @change="changeEmailType" placeholder="เลือกประเภทเทมเพลต" class="mr10">
                            <el-option
                                v-for="item in type_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="รหัสเทมเพลต">
                        <el-input v-model="form.mailId"></el-input>
                    </el-form-item>
                    <el-form-item label="ServerID">
                        <el-select filterable v-model="form.selceted_serverId" :placeholder="words.tips.PleaseSelectServerID" :disabled="form.emailType === 'personalemail'" class="mr10">
                            <el-option key="0" label="ทุกเซิร์ฟเวอร์" value="0" v-if="form.emailType === 'allserver'"></el-option>
                            <el-option
                                v-for="item in server_list"
                                :key="item.$.id"
                                :label="item.$.name"
                                :value="item.$.id"
                            ></el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="UID">
                        <el-input v-model="form.uidList" :disabled="form.emailType === 'allserver'"></el-input>
                    </el-form-item>
                    <el-form-item label="ไอเทม 1">
                        <el-select v-model="form.rewardType1" :disabled="form.emailType === 'allserver'" placeholder="ประเภท" class="mr10 parameter" @change="changeRewardType">
                            <el-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </el-option>
                        </el-select>
                        <el-input v-model="form.rewardUid1" :disabled="form.emailType === 'allserver'" placeholder="ID" class="parameter"></el-input>
                        <el-input v-model="form.rewardNum1" :disabled="form.emailType === 'allserver'" placeholder="จำนวน" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam11" :disabled="form.emailType === 'allserver'" :placeholder="reward1Params.param11" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam12" :disabled="form.emailType === 'allserver'" :placeholder="reward1Params.param12" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam13" :disabled="form.emailType === 'allserver'" :placeholder="reward1Params.param13" class="parameter"></el-input>
                    </el-form-item>
                    <el-form-item label="ไอเทม 2">
                        <el-select v-model="form.rewardType2" :disabled="form.emailType === 'allserver'" placeholder="ประเภท" class="mr10 parameter" @change="changeRewardType">
                            <el-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </el-option>
                        </el-select>
                        <el-input v-model="form.rewardUid2" :disabled="form.emailType === 'allserver'" placeholder="ID" class="parameter"></el-input>
                        <el-input v-model="form.rewardNum2" :disabled="form.emailType === 'allserver'" placeholder="จำนวน" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam21" :disabled="form.emailType === 'allserver'" :placeholder="reward2Params.param21" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam22" :disabled="form.emailType === 'allserver'" :placeholder="reward2Params.param22" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam23" :disabled="form.emailType === 'allserver'" :placeholder="reward2Params.param23" class="parameter"></el-input>
                    </el-form-item>
                    <el-form-item label="ไอเทม 3">
                        <el-select v-model="form.rewardType3" :disabled="form.emailType === 'allserver'" placeholder="ประเภท" class="mr10 parameter" @change="changeRewardType">
                            <el-option
                                v-for="item in reward_list"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </el-option>
                        </el-select>
                        <el-input v-model="form.rewardUid3" :disabled="form.emailType === 'allserver'" placeholder="ID" class="parameter"></el-input>
                        <el-input v-model="form.rewardNum3" :disabled="form.emailType === 'allserver'" placeholder="จำนวน" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam31" :disabled="form.emailType === 'allserver'" :placeholder="reward3Params.param31" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam32" :disabled="form.emailType === 'allserver'" :placeholder="reward3Params.param32" class="parameter"></el-input>
                        <el-input v-model="form.rewardParam33" :disabled="form.emailType === 'allserver'" :placeholder="reward3Params.param33" class="parameter"></el-input>
                    </el-form-item>
                    <el-form-item>
                        <el-button type="primary" @click="handleSendEmail">ส่งอีเมล</el-button>
                        <el-button @click="handleCancle">ยกเลิก</el-button>
                    </el-form-item>
                </el-form>
            </div>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElForm, ElFormItem, ElInput, ElOption, ElSelect } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElForm, ElFormItem, ElInput, ElOption, ElSelect },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                disabled: false,
                server_list: [],
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
                    selceted_serverId: '',
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
            this.getBaseInfo();
        },
        methods: {
            getBaseInfo () {
                let params = {
                    channel: getCookie('channel')
                }
                // 查询服务器列表
                this.$api.post('/api/baseinfo/serverlist',params)
                .then((res) => {
                    this.server_list = res.data.idspace.class;
                }).catch(function (err) {
                    console.log('fetch faild: ' + err);
                });
            },
            changeEmailType () {
                if (this.form.emailType === 'allserver') {
                    for (const key in this.form) {
                        this.form[key] = '';
                    }
                    this.form.emailType = 'allserver';
                } else {
                    this.form.mailId = '';
                    this.form.selceted_serverId = '';
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
                if (this.form.emailType === 'allserver' && this.form.mailId !== "" && this.form.selceted_serverId !== '') {
                    params = {
                        channel: getCookie('channel'),
                        mailId: this.form.mailId,
                        serverId: this.form.selceted_serverId
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
                            ElMessage.success('ส่งอีเมลแล้ว!')
                            for (const key in this.form) {
                                this.form[key] = '';
                            }
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:'+err)
                    })
                } else {
                    ElMessage.error('กรุณากรอกเนื้อหาอีเมลให้ถูกต้อง');
                }
            },
            handleCancle () {
                for (const key in this.form) {
                    this.form[key] = '';
                }
            }
        }
    }
</script>

<style scoped>
    .form-box {
        width: 80%;
    }
    .el-select {
        display: block;
    }
    .parameter {
        display: inline-block;
        width: 16%;
    }
</style>
