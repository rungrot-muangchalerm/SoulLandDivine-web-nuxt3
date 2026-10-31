<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-date"></i> ค้นหาบันทึก</el-breadcrumb-item>
                <el-breadcrumb-item>เข้าสู่ระบบ/ออกจากระบบ</el-breadcrumb-item>
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
                <el-select v-model="selected_type" placeholder="ประเภทการเข้าสู่ระบบ/ออกจากระบบ" class="mr10">
                    <el-option
                        v-for="item in typelist"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value">
                    </el-option>
                </el-select>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch(cur_page,page_size)">ค้นหา</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="uid" label="uid" align="center"></el-table-column>
                <el-table-column prop="accountId" label="ชื่อบัญชี" align="center"></el-table-column>
                <el-table-column prop="name" label="ชื่อตัวละคร" align="center"></el-table-column>
                <el-table-column prop="serverId" label="serverID" align="center"></el-table-column>
                <el-table-column prop="level" label="level" align="center"></el-table-column>
                <el-table-column prop="channel" label="ช่องทาง" align="center"></el-table-column>
                <el-table-column prop="time" label="เวลาเข้าสู่ระบบ/ออกจากระบบ" align="center"></el-table-column>
                <el-table-column prop="isLogin" label="ประเภทการเข้าสู่ระบบ/ออกจากระบบ" align="center"></el-table-column>
                <el-table-column prop="ip" label="IP" align="center"></el-table-column>
                <el-table-column prop="exp" label="ค่าประสบการณ์" align="center"></el-table-column>
                <el-table-column prop="diamond" label="เพชร" align="center"></el-table-column>
                <el-table-column prop="gold" label="ทอง" align="center"></el-table-column>
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
            // 查询登入、登出信息
            handleSearch (cur_page,page_size) {
                if (this.selceted_serverId === "" || this.uid==="" || this.selected_time==="" || this.selected_type==="") {
                    ElMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบถ้วน');
                } else {
                    var params = {
                        serverId: this.selceted_serverId,
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
