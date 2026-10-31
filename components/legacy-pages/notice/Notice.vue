<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-news"></i>ประกาศ</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <div class="content-title">อัปโหลดไฟล์ประกาศ</div>
                <el-upload
                    class="upload-demo"
                    ref="upload"
                    :action="uploadAction"
                    :data="uploadData"
                    :on-change="onChange"
                    :on-progress="handleProgress"
                    :on-remove="handleRemove"
                    :on-success="handleSuccess"
                    :on-error="handleError"
                    :auto-upload="false">
                    <el-button slot="trigger" size="small" type="primary">เลือกไฟล์</el-button>
                    <el-button style="margin-left: 10px;" size="small" type="success" @click="submitUpload">อัปโหลดไปยังเซิร์ฟเวอร์</el-button>
                </el-upload>
                <div class="content-title">ดาวน์โหลดไฟล์ประกาศ</div>
                <div class="crop-demo">
                    <el-input v-model="filename" placeholder="กรอกชื่อไฟล์" style="display:block"></el-input>
                    <el-button type="primary" @click="onDownload" style="margin-left:20px">ดาวน์โหลด</el-button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElInput, ElUpload } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElInput, ElUpload },
        data () {
            return {
                // 上传部分
                uploadData: {
                    fileName: '',
                    token: '7M664F6AR96XYI'
                },
                uploadAction: "/api/notice/upAnnouncement",
                // 下载部分
                filename: ''
            }
        },
        mounted(){

        },
        methods:{
           // 上传部分
            onChange (file) {
                this.uploadData.fileName = file.name
            },
            handleProgress () {
              console.log('上传')
            },
            handleRemove (file, fileList) {
                console.log(file, fileList);
            },
            handleError (err) {
                ElMessage.error(err)
            },
            // 点击按钮“上传到服务器”执行操作
            submitUpload () {
                if(this.uploadData.fileName === ""){
                    ElMessage.error('กรุณาอัปโหลดไฟล์ประกาศ!')
                    return
                }
                this.$refs.upload.submit();
            },
            // 文件上传后返回结果
            handleSuccess (response,file,fileList) {
                if(response.code === 1){
                    ElMessage.success('อัปโหลดประกาศสำเร็จ!')
                    this.$refs.upload.clearFiles()
                    this.$nextTick(()=>{
                        this.uploadData = {
                            fileName:'',
                            token: '7M664F6AR96XYI'
                        }
                    })
                }else if(response.code === 403) {
                    ElMessage.error('คุณไม่มีสิทธิ์ดำเนินการนี้')
                }
            },
            // 下载部分
            async onDownload () {
                if (this.filename === "") {
                    ElMessage.error('กรุณากรอกชื่อไฟล์ที่ต้องการดาวน์โหลด!')
                } else {
                    try {
                        window.open('/api/notice/downAnnouncement?fileName='+encodeURIComponent(this.filename))
                    }catch (e) {
                        console.log(e)
                    }
                }
            }
        }
    }
</script>

<style scoped>
    .content-title{
        font-weight: 400;
        line-height: 50px;
        margin: 10px 0;
        font-size: 22px;
        color: #1f2f3d;
    }
    .crop-demo{
        display: flex;
        align-items: flex-end;
    }
</style>
