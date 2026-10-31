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
        
        setup () { return { words: createAdminWords(), selectedServer: useCookie('selectedServer', { default: () => '' }) } },
        data () {
            return {
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    uid: '',
                    orderId: '',
                    orderInfo: '',
                    money: ''
                }
            }
        },
        methods: {
            handleOrder () {
                if (!this.selectedServer) {
                    BsMessage.error('กรุณาเลือกเซิร์ฟเวอร์จากแถบนำทาง');
                    return
                }
                for (var name in this.form) {
                    if (!this.form[name]) {
                        BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                        return
                    }
                }
                this.form.serverId = this.selectedServer;
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
                        this.form.uid = '';
                        this.form.orderId = '';
                        this.form.orderInfo = '';
                        this.form.money = '';
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

