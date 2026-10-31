<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="setting"></i> จัดการสิทธิ์</bs-breadcrumb-item>
                <bs-breadcrumb-item>ประวัติการดำเนินการ</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-select v-model="username" placeholder="ชื่อผู้ใช้" class="submitter mr10">
                    <bs-option key="all" label="all" value="all"></bs-option>
                    <bs-option v-for="item in allUsernames" :key="item.username" :label="item.username" :value="item.username"></bs-option>
                </bs-select>
                <bs-date-picker
                    v-model="time_data"
                    type="datetimerange"
                    :picker-options="words.time.pickerInterval"
                    range-separator="ถึง"
                    start-placeholder="เวลาเริ่มต้น"
                    end-placeholder="เวลาสิ้นสุด"
                    align="right"
                    class="time"
                    value-format="yyyy-MM-dd HH:mm:ss"
                ></bs-date-picker>
                <bs-select v-model="selectedType" placeholder="ประเภท" class="state mr10">
                    <bs-option key="all" label="ทั้งหมด" value="all"></bs-option>
                    <bs-option v-for="item in words.operation.operationList" :key="item.index" :label="item.label" :value="item.index"></bs-option>
                </bs-select>
                <bs-button type="primary" @click="handleSearch">ค้นหา</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="username" label="ชื่อผู้ใช้" align="center"></bs-table-column>
                <bs-table-column prop="time" label="เวลา" align="center"></bs-table-column>
                <bs-table-column prop="type" label="ประเภท" align="center"></bs-table-column>
                <bs-table-column prop="content" label="เนื้อหา" align="center"></bs-table-column>
                <bs-table-column prop="ip" label="IP" align="center"></bs-table-column>
            </bs-table>
            <bs-pagination
               
                background
                layout="prev, pager, next"
                :total="totalCount"
                :page-size="pageSize"
                v-model:current-page="currentPage"
             class="text-center"></bs-pagination>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
import { BsMessage } from '~/utils/bootstrap-message'
    export default {
        
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
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน')
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


