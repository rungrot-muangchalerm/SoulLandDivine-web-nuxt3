<template>
    <div>
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="magic-stick"></i>หักทรัพยากร</bs-breadcrumb-item>
                <bs-breadcrumb-item>หักความคืบหน้าการเติมเงินสะสม</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <bs-form ref="form" :model="form" label-width="100px">
                    <bs-form-item label="รหัสเซิร์ฟเวอร์">
                        <bs-select filterable v-model="form.ServerId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                            <bs-option 
                                v-for="item in server_list" 
                                :key="item.$.id" 
                                :label="item.$.name" 
                                :value="item.$.id"
                            ></bs-option>
                        </bs-select>
                    </bs-form-item>
                    <bs-form-item label="UID ผู้ใช้">
                        <bs-input v-model="form.UserId" placeholder="UID ผู้ใช้"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ความคืบหน้าที่ต้องหัก">
                        <bs-input v-model="form.Num" placeholder="กรอกจำนวนครั้งเข้าร่วมสะสมที่ต้องการหัก (อย่างน้อย 1 ครั้ง)"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="จำนวนเงินที่ต้องการหัก">
                        <bs-input v-model="form.Price" placeholder="กรอกจำนวนเงินที่ต้องการหัก"></bs-input>
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
        
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                server_list: [],
                form: {
                    ServerId: '',
                    UserId: '',
                    Num: '',
                    Price: ''
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
            handleDeduct () {
                let params = {
                    ServerId: this.form.ServerId,
                    ActivityType: '9',
                    UserId: this.form.UserId,
                    Num: this.form.Num,
                    Price: this.form.Price,
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


