<template>
  <main class="min-vh-100 bg-dark d-flex align-items-center justify-content-center p-3">
    <div class="row justify-content-center w-100">
      <div class="col-12 col-sm-10 col-md-7 col-lg-4">
        <section class="card shadow">
          <div class="card-body p-4">
            <h1 class="h4 text-center mb-4">{{ words.commonStructure.minstrelManagementSystem }}</h1>
            <bs-form ref="ruleForm" :model="ruleForm" :rules="rules">
              <bs-form-item prop="channel">
                <ClientOnly>
                  <bs-select v-model="ruleForm.channel" placeholder="เลือกช่องทาง" class="w-100">
                    <bs-option
                      v-for="item in channellist"
                      :key="item.index"
                      :label="item.name"
                      :value="item.index"
                    />
                  </bs-select>
                </ClientOnly>
              </bs-form-item>
              <bs-form-item prop="username">
                <bs-input v-model="ruleForm.username" placeholder="ชื่อผู้ใช้" autocomplete="username" />
              </bs-form-item>
              <bs-form-item prop="password">
                <bs-input
                  v-model="ruleForm.password"
                  type="password"
                  placeholder="รหัสผ่าน"
                  autocomplete="current-password"
                  @keyup.enter="submitForm('ruleForm')"
                />
              </bs-form-item>
              <div class="text-end mb-3">
                <button class="btn btn-link p-0 small" type="button" @click="handleForgotPsw">ลืมรหัสผ่าน</button>
              </div>
              <div class="d-grid">
                <bs-button type="primary" @click="submitForm('ruleForm')">เข้าสู่ระบบ</bs-button>
              </div>
              <p v-if="tips" class="text-danger small mt-3 mb-0">{{ tips }}</p>
            </bs-form>
          </div>
        </section>
      </div>
    </div>
  </main>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { setCookie } from '~/utils/cookies'

    import md5 from 'js-md5';
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
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
                                if (res.data.authorization === 'server') {
                                    this.$router.push('/server');
                                } else {
                                    this.$router.push('/role');
                                }
                                BsMessage.success(res.data.message);
                            } else {
                                this.tips = res.data.message
                            }
                        }).catch((err) => {
                            this.tips = err?.data?.statusMessage || 'เข้าสู่ระบบไม่สำเร็จ';
                            BsMessage.error(this.tips);
                        });

                    } else {
                        return false;
                    }
                });
            },
            handleForgotPsw () {
                BsMessage.warning('กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน');
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
