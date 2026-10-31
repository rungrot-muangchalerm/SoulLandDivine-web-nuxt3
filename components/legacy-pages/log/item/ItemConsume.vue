<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="date"></i> ค้นหาบันทึก</bs-breadcrumb-item>
                <bs-breadcrumb-item>ค้นหาการใช้ไอเทม</bs-breadcrumb-item>
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
                <bs-input class="uid mr10" placeholder="กรอก itemId" v-model="itemId"></bs-input>
                <bs-date-picker
                    v-model="selected_time"
                    type="datetimerange"
                    :picker-options="words.time.pickerInterval"
                    range-separator="ถึง"
                    start-placeholder="เวลาเริ่มต้น"
                    end-placeholder="เวลาสิ้นสุด"
                    align="right"
                    class="time"
                    value-format="yyyy-MM-dd HH:mm:ss"
                ></bs-date-picker>
                <bs-select filterable v-model="selected_consume" placeholder="ช่องทางการใช้" class="mr10">
                    <bs-option
                        v-for="item in words.myListArr.consumeWay"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value">
                    </bs-option>
                </bs-select>
                <bs-switch
                    v-model="order"
                    active-text="เก่าไปใหม่"
                    inactive-text="ใหม่ไปเก่า">
                </bs-switch>
                <bs-button type="primary" @click="handleSearch(cur_page,page_size)">ค้นหา</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="uid" label="uid" align="center"></bs-table-column>
                <bs-table-column prop="modelId" label="รหัสไอเทม" align="center"></bs-table-column>
                <bs-table-column prop="time" label="เวลา" align="center"></bs-table-column>
                <bs-table-column prop="level" label="level" align="center"></bs-table-column>
                <bs-table-column prop="channel" label="ช่องทาง" align="center"></bs-table-column>
                <bs-table-column prop="way" label="ช่องทางการใช้" align="center"></bs-table-column>
                <bs-table-column prop="type" label="ประเภทการใช้" align="center"></bs-table-column>
                <bs-table-column prop="changeNum" label="จำนวนที่ใช้" align="center"></bs-table-column>
                <bs-table-column prop="currNum" label="จำนวนปัจจุบัน" align="center"></bs-table-column>
                <bs-table-column prop="extraParam" label="พารามิเตอร์เพิ่มเติม" align="center"></bs-table-column>
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
                itemId: '',
                selected_time: '',
                selected_consume: '',
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
                if (this.selceted_serverId === "" || this.uid === "" || this.selected_time === "" || this.selected_consume ==="") {
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน');
                } else {
                    var params = {
                        serverId: this.selceted_serverId,
                        PcUid: this.uid,
                        itemId: this.itemId,
                        order: this.order,
                        ConsumeWay: this.selected_consume,
                        time_data: this.selected_time,
                        page: cur_page,
                        pageSize: page_size,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/log/searchItemConsume', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            this.tableData = res.data.list;
                            this.total_size = res.data.count;
                        } else {
                            this.tableData = [];
                            BsMessage.warning('ไม่พบข้อมูล');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                }
            }
        }
    }
</script>


