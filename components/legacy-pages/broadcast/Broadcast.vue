<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-bell"></i>ประกาศข้อความ</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-button type="success" icon="el-icon-edit" @click="handleAdd">{{ words.button.add }}</el-button>
                <el-select filterable v-model="selceted_serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                    <el-option key="0" label="all servers" value="0"></el-option>
                    <el-option 
                        v-for="item in server_list" 
                        :key="item.$.id" 
                        :label="item.$.name" 
                        :value="item.$.id"
                    ></el-option>
                </el-select>
                <el-select v-model="selceted_user" placeholder="ผู้ส่ง" class="mr10">
                    <el-option key="all" label="all users" value="all"></el-option>
                    <el-option 
                        v-for="item in user_list"
                        :key="item.id" 
                        :label="item.username" 
                        :value="item.username">
                    </el-option>
                </el-select>
                <el-select v-model="selceted_state" placeholder="สถานะ" class="mr10">
                    <el-option 
                        v-for="item in state_list"
                        :key="item.id" 
                        :label="item.label" 
                        :value="item.id">
                    </el-option>
                </el-select>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch">{{ words.button.search }}</el-button>
            </div>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="serverId" label="ServerId" align="center"></el-table-column>
                <el-table-column prop="title" label="หัวข้อ" align="center"></el-table-column>
                <el-table-column prop="submitter" label="ผู้ส่ง" align="center"></el-table-column>
                <el-table-column prop="createdAt" label="เวลาส่ง" align="center"></el-table-column>
                <el-table-column prop="type" label="ประเภท" align="center"></el-table-column>
                <el-table-column prop="status" label="สถานะ" align="center"></el-table-column>
                <el-table-column label="การดำเนินการ" width="150" align="center">
                    <template slot-scope="scope">
                        <el-button type="text" @click="handleChange(scope.$index,scope.row)">แก้ไข</el-button>
                        <el-button type="text" style="color: #f56c6c;" @click="handleDelete(scope.$index,scope.row)">ลบ</el-button>
                    </template>
                </el-table-column>
            </el-table>
            <!-- <div class="pagination">
                <el-pagination @current-change="handleCurrentChange" layout="prev, pager, next" :total="1000">
                </el-pagination>
            </div> -->
        </div>
        <!-- 弹窗 -->
        <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="35%" center :close-on-click-modal="false">
            <div class="del-dialog-cnt" v-if="this.dialogType === 'delete'">{{ dialogInfo }}</div>
            <el-form :model="form" label-width="120px" v-if="this.dialogType === 'add' || this.dialogType === 'change'">
                <el-form-item label="serverId">
                    <el-select filterable v-model="form.serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                        <el-option key="0" label="all servers" value="0"></el-option>
                        <el-option 
                            v-for="item in server_list" 
                            :key="item.$.id" 
                            :label="item.$.name" 
                            :value="item.$.id"
                        ></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="หัวข้อ">
                    <el-input v-model="form.title"></el-input>
                </el-form-item>
                <el-form-item label="เนื้อหาประกาศ">
                    <el-input
                        type="textarea"
                        autosize
                        placeholder="กรอกเนื้อหา"
                        v-model="form.content"
                    ></el-input>
                </el-form-item>
                <el-form-item label="ประเภทประกาศ">
                    <el-select v-model="form.type" placeholder="กรุณาเลือก">
                        <el-option key="once" label="ครั้งเดียว" value="once"></el-option>
                        <el-option key="loop" label="วนซ้ำ" value="loop"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="เวลาที่กำหนด">
                    <el-date-picker
                        v-model="form.startTime"
                        type="datetime"
                        placeholder="เลือกวันที่และเวลา"
                        default-time="12:00:00"
                        value-format="yyyy-MM-dd HH:mm:ss"
                    ></el-date-picker>
                </el-form-item>
                <el-form-item label="เวลาสิ้นสุด">
                    <el-date-picker
                        v-model="form.stopTime"
                        type="datetime"
                        placeholder="เลือกวันที่และเวลา"
                        default-time="12:00:00"
                        value-format="yyyy-MM-dd HH:mm:ss"
                        :disabled="form.type === 'once'"
                    ></el-date-picker>
                </el-form-item>
                <el-form-item label="ช่วงเวลา (นาที)">
                    <el-input v-model="form.intervalTime" :disabled="form.type === 'once'"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="dialogVisible = false">ยกเลิก</el-button>
                <el-button type="primary" @click="handleConfirm">ยืนยัน</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElDatePicker, ElDialog, ElForm, ElFormItem, ElInput, ElOption, ElPagination, ElSelect, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                username: getCookie('username'),
                selceted_serverId: '',
                selceted_user: '',
                user_list: [],
                selceted_state: '',
                state_list: [{
                    id: 'all',
                    label: 'all state'
                },{
                    id: 'unexecuted',
                    label: 'ยังไม่ดำเนินการ'
                },{
                    id: 'executing',
                    label: 'กำลังดำเนินการ'
                },{
                    id: 'finish',
                    label: 'สิ้นสุดแล้ว'
                }],
                server_list: [],
                tableData: [],
                dialogVisible: false,
                dialogTitle: '',
                dialogType: '',
                dialogInfo: '',
                form: {
                    id: '',
                    serverId: '',
                    title: '',
                    content: '',
                    type: '',
                    startTime: '',
                    stopTime: '',
                    intervalTime: ''
                }
            }
        },
        mounted () {
            this.getBaseInfo();
        },
        methods: {
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
                // 查询用户列表
                this.$api.post('/api/baseinfo/userlist',params)
                .then((res) => {
                    this.user_list = res.data;
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                });
            },
            // 查询广告广播
            handleSearch () {
                if (this.selceted_serverId === '' || this.selceted_user === '' || this.selceted_state === '') {
                    ElMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบ');
                } else {
                    var params = {
                        serverId: this.selceted_serverId,
                        submitter: this.selceted_user,
                        state_data: this.selceted_state,
                        channel: getCookie('channel')
                    }
                    this.$api.post('/api/broadcast/search', params)
                    .then((res) => {
                        this.tableData = res.data;
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                }
            },
            handleAdd () {
                for (const key in this.form) {
                    this.form[key] = '';
                }
                this.dialogTitle = 'เพิ่มประกาศข้อความ';
                this.dialogType = 'add';
                this.dialogVisible = true;
            },
            handleChange (index, row) {
                this.idx = index;
                const item = this.tableData[index];
                this.form = {
                    id: item.id,
                    serverId: item.serverId,
                    title: item.title,
                    content: item.content,
                    type: item.type,
                    startTime: item.startTime,
                    stopTime: item.stopTime,
                    intervalTime: item.intervalTime
                }
                this.dialogTitle = 'แก้ไขประกาศข้อความ';
                this.dialogType = 'change';
                this.dialogVisible = true;
            },
            handleDelete (index, row) {
                this.idx = index;
                this.dialogTitle = 'ลบประกาศข้อความ';
                this.dialogType = 'delete';
                this.dialogInfo = 'การลบไม่สามารถกู้คืนได้ ยืนยันการลบหรือไม่?';
                this.dialogVisible = true;
            },
            getParams (type) {
                let params;
                if (type === 'once') {
                    params = {
                        serverId: this.form.serverId,
                        title: this.form.title,
                        content: this.form.content,
                        type: this.form.type,
                        startTime: this.form.startTime,
                        stopTime: new Date(new Date(this.form.startTime).getTime() + 10 * 1000),
                        channel: getCookie('channel'),
                        submitter: getCookie('username'),
                        triggerTime: this.form.startTime
                    }
                } else if (type === 'loop') {
                    params = {
                        serverId: this.form.serverId,
                        title: this.form.title,
                        content: this.form.content,
                        type: this.form.type,
                        startTime: this.form.startTime,
                        stopTime: this.form.stopTime,
                        intervalTime: this.form.intervalTime,
                        channel: getCookie('channel'),
                        submitter: getCookie('username'),
                        triggerTime: this.form.startTime
                    }
                }
                return params
            },
            handleConfirm () {
                if (this.dialogType === 'add') { //添加广告广播
                    let params = this.getParams (this.form.type);
                    if (params === undefined) {
                        ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                    } else {
                        for (var name in params) {
                            if (!params[name]) {
                                ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                                return
                            }
                        }
                    }
                    this.$api.post('/api/broadcast/add', params)
                    .then((res) => {
                        if (res.data.result === 1) {
                            ElMessage.success('เพิ่มสำเร็จ');
                            this.dialogVisible = false;
                            this.handleSearch();
                        } else {
                            ElMessage.error('เพิ่มประกาศไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                } else if (this.dialogType === 'change') { //修改广告广播
                    let params = this.getParams (this.form.type);
                    params.id = this.form.id;
                    if (params === undefined) {
                        ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                    } else {
                        for (var name in params) {
                            if (!params[name]) {
                                ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                                return
                            }
                        }
                    }
                    this.$api.post('/api/broadcast/update', params)
                    .then((res) => {
                        if (res.data[0] === 1) {
                            ElMessage.success(`แก้ไขประกาศสำเร็จ`);
                            this.dialogVisible = false;
                            this.handleSearch();
                        } else {
                            ElMessage.error('แก้ไขประกาศไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                } else if (this.dialogType === 'delete') { //删除广告广播
                    var params = {
                        id: this.tableData[this.idx].id
                    }
                    this.$api.post('/api/broadcast/delete', params)
                    .then((res) => {
                        if (res.data === 1) {
                            ElMessage.success('ลบสำเร็จ');
                            this.dialogVisible = false;
                            this.handleSearch();
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err)
                    })
                }
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
    .del-dialog-cnt {
        color: red;
        text-align: center;
        margin-bottom: 20px;
        font-size: 16px;
    }
    .el-button--text {
        text-decoration: underline;
    }
</style>
