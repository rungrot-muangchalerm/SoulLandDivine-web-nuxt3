<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="document"></i>คำต้องห้าม</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-input class="uid mr10" placeholder="กรอกคำต้องห้าม โดยห้ามเว้นว่างหรือกรอกเฉพาะช่องว่าง!" v-model="sensitiveword"></bs-input>
                <bs-button type="success" @click="handleAdd">{{ words.button.add }}</bs-button>
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
                    BsMessage.error('คำต้องห้ามต้องไม่เว้นว่าง')
                } else {
                    var params = {
                        content: this.sensitiveword.trim(),
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/sensitive/addword', params)
                    .then((res)=> {
                        if (res.data.result === 1) {
                            BsMessage.success('เพิ่มคำต้องห้ามสำเร็จ');
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


