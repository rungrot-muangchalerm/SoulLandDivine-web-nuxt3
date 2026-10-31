<template>
  <div class="container-fluid">
    <bs-breadcrumb>
      <bs-breadcrumb-item>ประกาศ</bs-breadcrumb-item>
    </bs-breadcrumb>
    <section class="card">
      <div class="card-body">
        <h2 class="h5 mb-3">อัปโหลดไฟล์ประกาศ</h2>
        <bs-upload
          ref="upload"
          :action="uploadAction"
          :data="uploadData"
          :on-change="onChange"
          :on-progress="handleProgress"
          :on-remove="handleRemove"
          :on-success="handleSuccess"
          :on-error="handleError"
          :auto-upload="false"
        >
          <bs-button type="success" size="small" @click="submitUpload">อัปโหลดไปยังเซิร์ฟเวอร์</bs-button>
        </bs-upload>
        <hr class="my-4">
        <h2 class="h5 mb-3">ดาวน์โหลดไฟล์ประกาศ</h2>
        <div class="row g-2">
          <div class="col-12 col-md-6">
            <bs-input v-model="filename" placeholder="กรอกชื่อไฟล์" />
          </div>
          <div class="col-auto">
            <bs-button type="primary" @click="onDownload">ดาวน์โหลด</bs-button>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import { BsMessage } from '~/utils/bootstrap-message'


    export default {
        
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
                BsMessage.error(err)
            },
            // 点击按钮“上传到服务器”执行操作
            submitUpload () {
                if(this.uploadData.fileName === ""){
                    BsMessage.error('กรุณาอัปโหลดไฟล์ประกาศ!')
                    return
                }
                this.$refs.upload.submit();
            },
            // 文件上传后返回结果
            handleSuccess (response,file,fileList) {
                if(response.code === 1){
                    BsMessage.success('อัปโหลดประกาศสำเร็จ!')
                    this.$refs.upload.clearFiles()
                    this.$nextTick(()=>{
                        this.uploadData = {
                            fileName:'',
                            token: '7M664F6AR96XYI'
                        }
                    })
                }else if(response.code === 403) {
                    BsMessage.error('คุณไม่มีสิทธิ์ดำเนินการนี้')
                }
            },
            // 下载部分
            async onDownload () {
                if (this.filename === "") {
                    BsMessage.error('กรุณากรอกชื่อไฟล์ที่ต้องการดาวน์โหลด!')
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

