<template>
  <div class="error-page">
      <div class="error-code">4<span>0</span>3</div>
      <div class="error-desc">อ๊ะ คุณไม่มีสิทธิ์เข้าถึงหน้านี้</div>
      <div class="error-handle">
          <bs-button class="error-btn" type="primary" size="large" @click="goBack">กลับไปหน้าก่อนหน้า</bs-button>
          <router-link to="/">
            <bs-button type="primary" size="large">กลับหน้าหลัก</bs-button>
          </router-link>
      </div>
  </div>
</template>

<script>
export default {
        
  methods: {
      goBack () {
          this.$router.go(-1);
      }
  }
}
</script>



