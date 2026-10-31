<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-wallet"></i>เติมเงินย้อนหลัง</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-form ref="form" :model="form" label-width="100px">
                    <el-form-item label="serverId">
                        <el-select filterable v-model="form.serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                            <el-option 
                                v-for="item in server_list" 
                                :key="item.$.id" 
                                :label="item.$.name" 
                                :value="item.$.id"
                            ></el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="รหัสตัวละคร">
                        <el-input v-model="form.uid"></el-input>
                    </el-form-item>
                    <el-form-item label="หมายเลขคำสั่งซื้อ">
                        <el-input v-model="form.orderId"></el-input>
                    </el-form-item>
                    <el-form-item label="ข้อมูลคำสั่งซื้อ">
                        <el-input v-model="form.orderInfo"></el-input>
                    </el-form-item>
                    <el-form-item label="จำนวนเงิน">
                        <el-input v-model="form.money"></el-input>
                    </el-form-item>
                    <el-form-item>
                        <el-button type="success" icon="el-icon-edit" @click="handleOrder()">เติมเงินย้อนหลัง</el-button>
                    </el-form-item>
                </el-form>
            </div>
        </div>
        <!-- 弹窗 -->
        <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="30%" center :close-on-click-modal="false">
            <div class="del-dialog-cnt">{{ dialogInfo }}</div>
            <span slot="footer" class="dialog-footer">
                <el-button @click="dialogVisible = false">ยกเลิก</el-button>
                <el-button type="primary" @click="handleConfirm">ยืนยัน</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElSelect } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElSelect },
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
                        ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
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
                        ElMessage.success('เติมเงินย้อนหลังสำเร็จ');
                        for (const key in this.form) {
                            this.form[key] = '';
                        }
                        this.dialogVisible = false;
                    } else {
                        ElMessage.error('เติมเงินย้อนหลังไม่สำเร็จ');
                    }
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            }
        }
    }
</script>

<style scoped>
    .handle-box {
        margin-bottom: 20px;
    }
    .el-select {
        display: block;
    }
    .submitter {
        width: 100px;
    }
    .state {
        width: 100px;
    }
    .time {
        width: 330px;
    }
    .del-dialog-cnt {
        color: red;
        text-align: center;
        margin-bottom: 20px;
        font-size: 16px;
    }
    .el-button--text {
        text-decoration: underline;
    }
</style>
