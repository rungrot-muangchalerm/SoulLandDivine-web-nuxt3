<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-magic-stick"></i>หักทรัพยากร</el-breadcrumb-item>
                <el-breadcrumb-item>หักความคืบหน้าการเติมเงินสะสม</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <el-form ref="form" :model="form" label-width="100px">
                    <el-form-item label="รหัสเซิร์ฟเวอร์">
                        <el-select filterable v-model="form.ServerId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                            <el-option 
                                v-for="item in server_list" 
                                :key="item.$.id" 
                                :label="item.$.name" 
                                :value="item.$.id"
                            ></el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="UID ผู้ใช้">
                        <el-input v-model="form.UserId" placeholder="UID ผู้ใช้"></el-input>
                    </el-form-item>
                    <el-form-item label="ความคืบหน้าที่ต้องหัก">
                        <el-input v-model="form.Num" placeholder="กรอกจำนวนครั้งเข้าร่วมสะสมที่ต้องการหัก (อย่างน้อย 1 ครั้ง)"></el-input>
                    </el-form-item>
                    <el-form-item label="จำนวนเงินที่ต้องการหัก">
                        <el-input v-model="form.Price" placeholder="กรอกจำนวนเงินที่ต้องการหัก"></el-input>
                    </el-form-item>
                    <el-form-item>
                        <el-button type="primary" icon="el-icon-delete" @click="handleDeduct">หัก</el-button>
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
                        ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                        return
                    }
                }
                this.$api.post('/api/itemdelete/deductPlan',params)
                .then((res) => {
                    if (res.data.result === 1) {
                        ElMessage.success(`หักความคืบหน้าของ ${params.UserId} จำนวน ${params.Num} สำเร็จ`);
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
