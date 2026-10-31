<template>
    <div>
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="magic-stick"></i>หักทรัพยากร</bs-breadcrumb-item>
                <bs-breadcrumb-item>หักความคืบหน้าการเติมเงินกิจกรรม</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <bs-form ref="form" :model="form" label-width="100px">
                    <bs-form-item label="เซิร์ฟเวอร์">{{ selectedServer || 'เลือกเซิร์ฟเวอร์ที่ Navbar' }}</bs-form-item>
                    <bs-form-item label="ประเภทกิจกรรม">
                        <bs-select v-model="form.ActivityType" placeholder="เลือกประเภทกิจกรรม" class="mr10">
                            <bs-option
                                v-for="item in words.resource.activity_type"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                            </bs-option>
                        </bs-select>
                    </bs-form-item>
                    <bs-form-item label="UID ผู้ใช้">
                        <bs-input v-model="form.UserId" placeholder="UID ผู้ใช้"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ความคืบหน้าที่ต้องหัก">
                        <bs-input v-model="form.Num" placeholder="กรอกจำนวนครั้งเข้าร่วมสะสมที่ต้องการหัก (อย่างน้อย 1 ครั้ง)"></bs-input>
                    </bs-form-item>
                    <bs-form-item>
                        <bs-button type="primary" @click="handleDeduct">หัก</bs-button>
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
                form: {
                    ActivityType: '',
                    UserId: '',
                    Num: ''
                }
            }
        },
        methods: {
            handleDeduct () {
                let params = {
                    ServerId: this.selectedServer,
                    ActivityType: this.form.ActivityType,
                    UserId: this.form.UserId,
                    Num: this.form.Num,
                    Price: '0',
                    channel: getCookie('channel')
                }
                for (let name in params) {
                    if (!params[name]) {
                        BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                        return
                    }
                }
                this.$api.post('/api/itemdelete/deductPlan',params)
                .then((res) => {
                    if (res.data.result === 1) {
                        BsMessage.success(`หักความคืบหน้าของ ${params.UserId} จำนวน ${params.Num} สำเร็จ`);
                        for (const key in this.form) {
                            this.form[key] = '';
                        }
                    }
                }).catch(function (err) {
                    console.log('fetch faild: ' + err);
                });
            }
        }
    }
</script>
