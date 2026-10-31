<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-date"></i> ค้นหาบันทึก</el-breadcrumb-item>
                <el-breadcrumb-item>ค้นหาการเติมเงิน</el-breadcrumb-item>
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
                <el-date-picker
                    v-model="selected_time"
                    type="daterange"
                    :picker-options="words.time.pickerInterval"
                    range-separator="ถึง"
                    start-placeholder="เวลาเริ่มต้น"
                    end-placeholder="เวลาสิ้นสุด"
                    align="right"
                    class="time"
                    value-format="yyyy-MM-dd"
                ></el-date-picker>
                <el-input class="uid mr10" placeholder="กรอกหมายเลขคำสั่งซื้อ" v-model="orderId"></el-input>
                <el-input class="uid mr10" placeholder="กรอกข้อมูลคำสั่งซื้อ" v-model="orderInfo"></el-input>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch(cur_page,page_size)">ค้นหา</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="orderId" label="หมายเลขคำสั่งซื้อ" align="center"></el-table-column>
                <el-table-column prop="orderInfo" label="ข้อมูลคำสั่งซื้อ" align="center"></el-table-column>
                <el-table-column prop="money" label="จำนวนเงิน" align="center"></el-table-column>
                <el-table-column prop="time" label="เวลา" align="center"></el-table-column>
                <el-table-column prop="state" label="สถานะการเติมเงิน" align="center"></el-table-column>
                <el-table-column prop="getState" label="สถานะการรับรางวัล" align="center"></el-table-column>
                <el-table-column prop="productId" label="รหัสสินค้า" align="center"></el-table-column>
                <el-table-column prop="productName" label="ชื่อสินค้า" align="center"></el-table-column>
                <el-table-column prop="rechargeWay" label="วิธีเติมเงิน" align="center"></el-table-column>
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
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElInput, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElInput, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                selceted_serverId: '',
                uid: '',
                selected_time: '',
                orderId: '',
                orderInfo: '',
                cur_page: 1,
                total_size: 1,
                page_size: 20,
                tableList: [],
                server_list: [],
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
            // 查询充值信息
            handleSearch (page,page_size) {
                if (this.selceted_serverId === "" || this.uid ==="" || this.selected_time ==="") {
                    ElMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน');
                } else {
                    var params = {
                        serverId: this.selceted_serverId,
                        uid: this.uid,
                        time_data: this.selected_time,
                        orderId: this.orderId,
                        orderInfo: this.orderInfo,
                        page: page,
                        pageSize: page_size,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/log/searchPay', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            this.tableData = res.data.orderList;
                            this.total_size = res.data.dataCount;
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
