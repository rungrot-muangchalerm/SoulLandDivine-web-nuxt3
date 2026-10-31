<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="date"></i> ค้นหาบันทึก</bs-breadcrumb-item>
                <bs-breadcrumb-item>เข้าสู่ระบบ/ออกจากระบบ</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
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
                <bs-select v-model="selected_type" placeholder="ประเภทการเข้าสู่ระบบ/ออกจากระบบ" class="mr10">
                    <bs-option
                        v-for="item in typelist"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value">
                    </bs-option>
                </bs-select>
                <bs-button type="primary" @click="handleSearch(cur_page,page_size)">ค้นหา</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="uid" label="uid" align="center"></bs-table-column>
                <bs-table-column prop="accountId" label="ชื่อบัญชี" align="center"></bs-table-column>
                <bs-table-column prop="name" label="ชื่อตัวละคร" align="center"></bs-table-column>
                <bs-table-column prop="serverId" label="serverID" align="center"></bs-table-column>
                <bs-table-column prop="level" label="level" align="center"></bs-table-column>
                <bs-table-column prop="channel" label="ช่องทาง" align="center"></bs-table-column>
                <bs-table-column prop="time" label="เวลาเข้าสู่ระบบ/ออกจากระบบ" align="center"></bs-table-column>
                <bs-table-column prop="isLogin" label="ประเภทการเข้าสู่ระบบ/ออกจากระบบ" align="center"></bs-table-column>
                <bs-table-column prop="ip" label="IP" align="center"></bs-table-column>
                <bs-table-column prop="exp" label="ค่าประสบการณ์" align="center"></bs-table-column>
                <bs-table-column prop="diamond" label="เพชร" align="center"></bs-table-column>
                <bs-table-column prop="gold" label="ทอง" align="center"></bs-table-column>
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
        
        setup () { return { words: createAdminWords(), selectedServer: useCookie('selectedServer', { default: () => '' }) } },
        data () {
            return {
                uid: '',
                selected_time: '',
                selected_type: '',
                typelist: [{
                    value: 'login',
                    label: 'เข้าสู่ระบบ'
                }, {
                    value: 'logout',
                    label: 'ออกจากระบบ'
                }],
                cur_page: 1,
                total_size: 1,
                page_size: 20,
                tableList: [],
                tableData: []
            }
        },
        methods: {
            // 分页导航
            handleCurrentChange(val) {
                this.handleSearch(val,this.page_size);
            },
            // 查询登入、登出信息
            handleSearch (cur_page,page_size) {
                if (!this.selectedServer || this.uid==="" || this.selected_time==="" || this.selected_type==="") {
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน');
                } else {
                    var params = {
                        serverId: this.selectedServer,
                        PcUid: this.uid,
                        way: this.selected_type,
                        time_data: this.selected_time,
                        page: cur_page,
                        pageSize: page_size,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/log/searchLoginOrLogOut', params)
                    .then(res => {
                        if (res.data.result === 1) {
                            for (let i = 0; i < res.data.list.length; i++) {
                                if (res.data.list[i].isLogin === true) {
                                    res.data.list[i].isLogin = 'เข้าสู่ระบบ';
                                } else {
                                    res.data.list[i].isLogin = 'ออกจากระบบ';
                                }
                            }
                            this.tableData = res.data.list;
                            this.total_size = res.data.count;
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

