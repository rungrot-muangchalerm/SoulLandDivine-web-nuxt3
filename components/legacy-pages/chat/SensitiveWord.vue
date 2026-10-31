<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-document"></i>คำต้องห้าม</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-input class="uid mr10" placeholder="กรอกคำต้องห้าม โดยห้ามเว้นว่างหรือกรอกเฉพาะช่องว่าง!" v-model="sensitiveword"></el-input>
                <el-button type="success" icon="el-icon-edit" @click="handleAdd">{{ words.button.add }}</el-button>
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
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElInput } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDialog, ElInput },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                sensitiveword: '',
                dialogTitle: '',
                dialogVisible: false,
                dialogInfo: ''
            }
        },
        methods: {
            // 新增敏感词
            handleAdd () {
                this.dialogTitle = 'เพิ่มคำต้องห้าม';
                this.dialogInfo = 'ยืนยันเพิ่มคำนี้ในรายการคำต้องห้ามหรือไม่?';
                this.dialogVisible = true;
            },
            handleConfirm () {
				if (this.sensitiveword.trim() ===  '') {
                    ElMessage.error('คำต้องห้ามต้องไม่เว้นว่าง')
                } else {
                    var params = {
                        content: this.sensitiveword.trim(),
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/sensitive/addword', params)
                    .then((res)=> {
                        if (res.data.result === 1) {
                            ElMessage.success('เพิ่มคำต้องห้ามสำเร็จ');
                            this.dialogVisible = false;
                            this.sensitiveword = '';
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:'+err);
                    });
                }
            }
        }
    }
</script>

<style scoped>
    .handle-box {
        margin-bottom: 20px;
    }
    .mr10 {
        width: 30%;
    }
    .del-dialog-cnt {
        color: red;
        text-align: center;
        margin-bottom: 20px;
    }
</style>
