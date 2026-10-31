<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-setting"></i> จัดการสิทธิ์</el-breadcrumb-item>
                <el-breadcrumb-item>ประวัติการดำเนินการ</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-select v-model="username" placeholder="ชื่อผู้ใช้" class="submitter mr10">
                    <el-option key="all" label="all" value="all"></el-option>
                    <el-option v-for="item in allUsernames" :key="item.username" :label="item.username" :value="item.username"></el-option>
                </el-select>
                <el-date-picker
                    v-model="time_data"
                    type="datetimerange"
                    :picker-options="words.time.pickerInterval"
                    range-separator="ถึง"
                    start-placeholder="เวลาเริ่มต้น"
                    end-placeholder="เวลาสิ้นสุด"
                    align="right"
                    class="time"
                    value-format="yyyy-MM-dd HH:mm:ss"
                ></el-date-picker>
                <el-select v-model="selectedType" placeholder="ประเภท" class="state mr10">
                    <el-option key="all" label="ทั้งหมด" value="all"></el-option>
                    <el-option v-for="item in words.operation.operationList" :key="item.index" :label="item.label" :value="item.index"></el-option>
                </el-select>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch">ค้นหา</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="username" label="ชื่อผู้ใช้" align="center"></el-table-column>
                <el-table-column prop="time" label="เวลา" align="center"></el-table-column>
                <el-table-column prop="type" label="ประเภท" align="center"></el-table-column>
                <el-table-column prop="content" label="เนื้อหา" align="center"></el-table-column>
                <el-table-column prop="ip" label="IP" align="center"></el-table-column>
            </el-table>
            <el-pagination
                style="text-align: center;margin-top: 12px"
                background
                layout="prev, pager, next"
                :total="totalCount"
                :page-size="pageSize"
                :current-page.sync="currentPage"
            ></el-pagination>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn } from 'element-plus'
    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data() {
            return {
                username: '',
                allUsernames: null,
                selectedType: '',
                tableData: [],
                time_data: '',
                totalCount:undefined,  //查询结果总条数
                currentPage:1,
                pageSize:10,
            }
        },
        mounted(){
            this.searchAllUsers()
        },
        /* watch:{
            currentPage(val){
                this.handleSearch()
            }
        }, */
        methods: {
            // 获取所有用户名
            async searchAllUsers(){
                var self = this
                var result = await this.$api.post('/api/users/searchall').catch(function (err) {
                    console.log('err:' + err)
                })
                this.allUsernames = result.data
            },
            // 查询操作日志
            handleSearch(){
                if (this.username === "" || this.selectedType === "") {
                    ElMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน')
                } else {
                    var self = this
                    var params = {
                        username: this.username,
                        time: this.time_data,
                        type: this.selectedType
                        // offset:this.pageSize*(this.currentPage-1),
                        // limit:this.pageSize
                    }
                    this.$api.post('/api/users/findLogs',params).then((res)=> {
                        this.tableData = res.data;
                        // 把英文的分类名称转成中文显示
                        this.tableData.forEach((resItem) => {
                            self.words.operation.operationList.forEach((storeItem) => {
                                if(storeItem.index === resItem.type){
                                    resItem.type = storeItem.label
                                }
                            })
                        })
                        // this.getTotalCount()
                    }).catch(function (err) {
                        console.log('fetch faild:'+err)
                    })
                }
            },
            getTotalCount(){
                const self = this
                var params = {
                    username : this.username,
                    time_data:this.time_data,
                    category:this.selectedCategory
                }
                this.$api.post('/api/users/logTotalCount',params).then(function (response) {
                    self.totalCount = response.data.totalCount

                })
            }
        }
    }
</script>

<style scoped>
    .handle-box {
        margin-bottom: 20px;
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
</style>
