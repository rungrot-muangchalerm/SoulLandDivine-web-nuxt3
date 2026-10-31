<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="date"></i> ค้นหาบันทึก</bs-breadcrumb-item>
                <bs-breadcrumb-item>ค้นหาการเติมเงิน</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-select filterable v-model="selceted_serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                    <bs-option 
                        v-for="item in server_list" 
                        :key="item.$.id" 
                        :label="item.$.name" 
                        :value="item.$.id"
                    ></bs-option>
                </bs-select>
                <bs-input class="uid mr10" placeholder="กรอก uid" v-model="uid"></bs-input>
                <bs-date-picker
                    v-model="selected_time"
                    type="daterange"
                    :picker-options="words.time.pickerInterval"
                    range-separator="ถึง"
                    start-placeholder="เวลาเริ่มต้น"
                    end-placeholder="เวลาสิ้นสุด"
                    align="right"
                    class="time"
                    value-format="yyyy-MM-dd"
                ></bs-date-picker>
                <bs-input class="uid mr10" placeholder="กรอกหมายเลขคำสั่งซื้อ" v-model="orderId"></bs-input>
                <bs-input class="uid mr10" placeholder="กรอกข้อมูลคำสั่งซื้อ" v-model="orderInfo"></bs-input>
                <bs-button type="primary" @click="handleSearch(cur_page,page_size)">ค้นหา</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="orderId" label="หมายเลขคำสั่งซื้อ" align="center"></bs-table-column>
                <bs-table-column prop="orderInfo" label="ข้อมูลคำสั่งซื้อ" align="center"></bs-table-column>
                <bs-table-column prop="money" label="จำนวนเงิน" align="center"></bs-table-column>
                <bs-table-column prop="time" label="เวลา" align="center"></bs-table-column>
                <bs-table-column prop="state" label="สถานะการเติมเงิน" align="center"></bs-table-column>
                <bs-table-column prop="getState" label="สถานะการรับรางวัล" align="center"></bs-table-column>
                <bs-table-column prop="productId" label="รหัสสินค้า" align="center"></bs-table-column>
                <bs-table-column prop="productName" label="ชื่อสินค้า" align="center"></bs-table-column>
                <bs-table-column prop="rechargeWay" label="วิธีเติมเงิน" align="center"></bs-table-column>
            </bs-table>
            <div class="pagination">
                <bs-pagination @current-change="handleCurrentChange" layout="prev, pager, next" :total="total_size" :page-size="page_size">
                </bs-pagination>
            </div>
        </div>
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
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน');
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
                            BsMessage.warning('ไม่พบข้อมูล');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    });
                }
            }
        }
    }
</script>


