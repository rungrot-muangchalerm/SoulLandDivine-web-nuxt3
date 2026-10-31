<template>
    <div class="login-wrap">
        <div class="ms-title">{{ words.commonStructure.minstrelManagementSystem }}</div>
        <div class="ms-login">
            <el-form :model="ruleForm" :rules="rules" ref="ruleForm" class="demo-ruleForm">
                <el-form-item prop="channel">
                    <ClientOnly>
                        <el-select v-model="ruleForm.channel" placeholder="เลือกช่องทาง" style="width: 100%">
                            <el-option
                                v-for="item in channellist"
                                :key="item.index"
                                :label="item.name"
                                :value="item.index"
                            ></el-option>
                        </el-select>
                    </ClientOnly>
                </el-form-item>
                <el-form-item prop="username">
                    <el-input v-model="ruleForm.username" placeholder="ชื่อผู้ใช้"></el-input>
                </el-form-item>
                <el-form-item prop="password">
                    <el-input type="password" placeholder="รหัสผ่าน" v-model="ruleForm.password" show-password @keyup.enter.native="submitForm('ruleForm')"></el-input>
                </el-form-item>
                <div class="aboutPsw">
                    <!-- <el-checkbox v-model="rememberPsw">记住密码</el-checkbox> -->
                    <span style="font-size:12px;line-height:30px;color:#999;float:right;text-decoration:underline;cursor:pointer;" @click="handleForgotPsw">ลืมรหัสผ่าน</span>
                </div>
                <div class="login-btn">
                    <el-button type="primary" @click="submitForm('ruleForm')">เข้าสู่ระบบ</el-button>
                </div>
                <p style="font-size:12px;line-height:30px;color:red;">{{ tips }}</p>
            </el-form>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElButton, ElCheckbox, ElForm, ElFormItem, ElInput, ElOption, ElSelect } from 'element-plus'

    import md5 from 'js-md5';

    export default {
        components: { ElButton, ElCheckbox, ElForm, ElFormItem, ElInput, ElOption, ElSelect },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                ruleForm: {
                    channel: '',
                    username: '',
                    password: ''
                },
                rules: {
                    channel: [
                        { required: true, message: 'กรุณาเลือกช่องทาง', trigger: 'blur' }
                    ],
                    username: [
                        { required: true, message: 'กรุณากรอกชื่อผู้ใช้', trigger: 'blur' }
                    ],
                    password: [
                        { required: true, message: 'กรุณากรอกรหัสผ่าน', trigger: 'blur' }
                    ]
                },
                rememberPsw: false,
                tips: '',
                channellist: []
            }
        },
        mounted () {
            // console.log(md5('yyb'+'123456'));
            this.searchChannel();
        },
        methods: {
            submitForm (formName) {
                this.$refs[formName].validate(async (valid) => {
                    if (valid) {
                        // localStorage.setItem('ms_username',this.ruleForm.username);
                        const username = this.ruleForm.username.trim();
                        var params = {
                            channel: this.ruleForm.channel,
                            username,
                            password: md5(username + this.ruleForm.password)
                        }
                        setCookie('username', username);
                        setCookie('channel',this.ruleForm.channel);
                        this.$api.post('/api/login', params)
                        .then((res)=> {
                            if (res.data.code === 1) {
                                setCookie('authorization', res.data.authorization);
                                if (getCookie('authorization') === 'server') {
                                    this.$router.push('/server');
                                } else {
                                    this.$router.push('/role');
                                }
                                ElMessage.success(res.data.message);
                            } else {
                                this.tips = res.data.message
                            }
                        }).catch((err) => {
                            this.tips = err?.data?.statusMessage || 'เข้าสู่ระบบไม่สำเร็จ';
                            ElMessage.error(this.tips);
                        });

                    } else {
                        return false;
                    }
                });
            },
            handleForgotPsw () {
                ElMessage.warning('กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน');
            },
            // 获取渠道列表
            searchChannel () {
                this.$api.post('/api/set/searchChannel')
                .then((res) => {
                    this.channellist = res.data;
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                })
            }
        }
    }
</script>

<style scoped>
    .login-wrap{
        position: relative;
        width:100%;
        min-height:100vh;
        height:100vh;
        background:#324157;
    }
    .ms-title{
        position: absolute;
        top:50%;
        width:100%;
        margin-top: -230px;
        text-align: center;
        font-size:30px;
        color: #fff;
    }
    .ms-login{
        position: absolute;
        left:50%;
        top:50%;
        width:300px;
        box-sizing:content-box;
        margin:-150px 0 0 -190px;
        padding:40px;
        border-radius: 5px;
        background: #fff;
    }
    .login-btn{
        text-align: center;
    }
    .login-btn button{
        width:100%;
        height:36px;
    }
</style>
