<template>
  <div class="error-page">
      <div class="error-code">4<span>0</span>3</div>
      <div class="error-desc">อ๊ะ คุณไม่มีสิทธิ์เข้าถึงหน้านี้</div>
      <div class="error-handle">
          <el-button class="error-btn" type="primary" size="large" @click="goBack">กลับไปหน้าก่อนหน้า</el-button>
          <router-link to="/">
            <el-button type="primary" size="large">กลับหน้าหลัก</el-button>
          </router-link>
      </div>
  </div>
</template>

<script>
    import { ElButton } from 'element-plus'
export default {
        components: { ElButton },
  methods: {
      goBack () {
          this.$router.go(-1);
      }
  }
}
</script>


<style scoped>
    .error-page{
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        width: 100%;
        height: 100%;
        background: #f3f3f3;
        box-sizing: border-box;
    }
    .error-code{
        line-height: 1;
        font-size: 250px;
        font-weight: bolder;
        color: #f02d2d;
    }
    .error-code span{
        color: #00a854;
    }
    .error-desc{
        font-size: 30px;
        color: #777;
    }
    .error-handle{
        margin-top: 30px;
        padding-bottom: 200px;
    }
    .error-btn{
        margin-left: -10px;
        margin-right: 140px;
    }
</style>
