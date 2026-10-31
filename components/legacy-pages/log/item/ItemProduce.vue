<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-date"></i> ค้นหาบันทึก</el-breadcrumb-item>
                <el-breadcrumb-item>ค้นหาการได้รับไอเทม</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-select filterable v-model="selceted_serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                    <el-option 
                        v-for="item in server_list" 
                        :key="item.$.id" 
                        :label="item.$.name" 
                        :value="item.$.id"
                    ></el-option>
                </el-select>
                <el-input class="uid mr10" placeholder="กรอก uid" v-model="uid"></el-input>
                <el-input class="uid mr10" placeholder="กรอก itemId" v-model="itemId"></el-input>
                <el-date-picker
                    v-model="selected_time"
                    type="datetimerange"
                    :picker-options="words.time.pickerInterval"
                    range-separator="ถึง"
                    start-placeholder="เวลาเริ่มต้น"
                    end-placeholder="เวลาสิ้นสุด"
                    align="right"
                    class="time"
                    value-format="yyyy-MM-dd HH:mm:ss"
                ></el-date-picker>
                <el-select filterable v-model="selected_obtain" placeholder="ช่องทางที่ได้รับ" class="mr10">
                    <el-option
                        v-for="item in words.myListArr.gainWay"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value">
                    </el-option>
                </el-select>
                <el-switch
                    v-model="order"
                    active-text="เก่าไปใหม่"
                    inactive-text="ใหม่ไปเก่า">
                </el-switch>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch(cur_page,page_size)">ค้นหา</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="uid" label="uid" align="center"></el-table-column>
                <el-table-column prop="modelId" label="รหัสไอเทม" align="center"></el-table-column>
                <el-table-column prop="time" label="เวลา" align="center"></el-table-column>
                <el-table-column prop="level" label="level" align="center"></el-table-column>
                <el-table-column prop="channel" label="ช่องทาง" align="center"></el-table-column>
                <el-table-column prop="way" label="ช่องทางที่ได้รับ" align="center"></el-table-column>
                <el-table-column prop="type" label="ประเภทการได้รับ" align="center"></el-table-column>
                <el-table-column prop="changeNum" label="จำนวนที่ได้รับ" align="center"></el-table-column>
                <el-table-column prop="currNum" label="จำนวนปัจจุบัน" align="center"></el-table-column>
                <el-table-column prop="extraParam" label="พารามิเตอร์เพิ่มเติม" align="center"></el-table-column>
            </el-table>
            <div class="pagination">
                <el-pagination @current-change="handleCurrentChange" layout="prev, pager, next" :total="total_size" :page-size="page_size">
                </el-pagination>
            </div>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElInput, ElOption, ElPagination, ElSelect, ElSwitch, ElTable, ElTableColumn } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElInput, ElOption, ElPagination, ElSelect, ElSwitch, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                selceted_serverId: '',
                uid: '',
                itemId: '',
                selected_time: '',
                selected_obtain: '',
                order: true,
                server_list: [],
                cur_page: 1,
                total_size: 1,
                page_size: 20,
                tableData: []
            }
        },
        mounted () {
            this.getBaseInfo();
        },
        methods: {
            // 分页导航
            handleCurrentChange(val) {
                this.handleSearch(val,this.page_size);
            },
            getBaseInfo () {
                let params = {
                    channel: getCookie('channel')
                }
                // 查询服务器列表
                this.$api.post('/api/baseinfo/serverlist',params)
                .then((res) => {
                    this.server_list = res.data.idspace.class;
                }).catch(function (err) {
                    console.log('fetch faild: ' + err);
                });
            },
            handleSearch (cur_page,page_size) {
                if (this.selceted_serverId === "" || this.uid === "" || this.selected_time === "" || this.selected_obtain ==="") {
                    ElMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน');
                } else {
                    var params = {
                        serverId: this.selceted_serverId,
                        PcUid: this.uid,
                        itemId: this.itemId,
                        order: this.order,
                        ObtainWay: this.selected_obtain,
                        time_data: this.selected_time,
                        page: cur_page,
                        pageSize: page_size,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/log/searchItemProduce', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            this.tableData = res.data.list;
                            this.total_size = res.data.count;
                        } else {
                            this.tableData = [];
                            ElMessage.warning('ไม่พบข้อมูล');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
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

    .uid {
        width: 15%;
    }

</style>
