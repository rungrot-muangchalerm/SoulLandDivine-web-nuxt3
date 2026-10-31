<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="wallet"></i>เติมเงินย้อนหลัง</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-form ref="form" :model="form" label-width="100px">
                    <bs-form-item label="serverId">
                        <bs-select filterable v-model="form.serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                            <bs-option 
                                v-for="item in server_list" 
                                :key="item.$.id" 
                                :label="item.$.name" 
                                :value="item.$.id"
                            ></bs-option>
                        </bs-select>
                    </bs-form-item>
                    <bs-form-item label="รหัสตัวละคร">
                        <bs-input v-model="form.uid"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="หมายเลขคำสั่งซื้อ">
                        <bs-input v-model="form.orderId"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="ข้อมูลคำสั่งซื้อ">
                        <bs-input v-model="form.orderInfo"></bs-input>
                    </bs-form-item>
                    <bs-form-item label="จำนวนเงิน">
                        <bs-input v-model="form.money"></bs-input>
                    </bs-form-item>
                    <bs-form-item>
                        <bs-button type="success" @click="handleOrder()">เติมเงินย้อนหลัง</bs-button>
                    </bs-form-item>
                </bs-form>
            </div>
        </div>
        <!-- 弹窗 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" width="30%" center :close-on-click-modal="false">
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false">ยกเลิก</bs-button>
                <bs-button type="primary" @click="handleConfirm">ยืนยัน</bs-button>
            </div></template>
        </bs-dialog>
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
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    serverId: '',
                    uid: '',
                    orderId: '',
                    orderInfo: '',
                    money: ''
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
            handleOrder () {
                for (var name in this.form) {
                    if (!this.form[name]) {
                        BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                        return
                    }
                }
                this.form.channel = getCookie('channel')
                this.dialogTitle = 'ยืนยันเติมเงินย้อนหลัง';
                this.dialogVisible = true;
                this.dialogInfo = 'ยืนยันเติมเงินย้อนหลังให้ผู้เล่น ' + this.form.uid + ' บนเซิร์ฟเวอร์ ' + this.form.serverId + ' จำนวน ' + this.form.money + ' หยวนหรือไม่?'
            },
            handleConfirm () {
                this.$api.post('/api/pay/order', this.form)
                .then((res) => {
                    if (res.data.result === 1) {
                        BsMessage.success('เติมเงินย้อนหลังสำเร็จ');
                        for (const key in this.form) {
                            this.form[key] = '';
                        }
                        this.dialogVisible = false;
                    } else {
                        BsMessage.error('เติมเงินย้อนหลังไม่สำเร็จ');
                    }
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            }
        }
    }
</script>


