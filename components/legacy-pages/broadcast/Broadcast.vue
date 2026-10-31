<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="bell"></i>ประกาศข้อความ</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-button type="success" @click="handleAdd">{{ words.button.add }}</bs-button>
                <span class="badge text-bg-secondary">{{ selectedServer ? `เซิร์ฟเวอร์ ${selectedServer}` : 'เลือกเซิร์ฟเวอร์ที่ Navbar' }}</span>
                <bs-select v-model="selceted_user" placeholder="ผู้ส่ง" class="mr10">
                    <bs-option key="all" label="all users" value="all"></bs-option>
                    <bs-option 
                        v-for="item in user_list"
                        :key="item.id" 
                        :label="item.username" 
                        :value="item.username">
                    </bs-option>
                </bs-select>
                <bs-select v-model="selceted_state" placeholder="สถานะ" class="mr10">
                    <bs-option 
                        v-for="item in state_list"
                        :key="item.id" 
                        :label="item.label" 
                        :value="item.id">
                    </bs-option>
                </bs-select>
                <bs-button type="primary" @click="handleSearch">{{ words.button.search }}</bs-button>
            </div>
            <bs-table :data="tableData" border ref="multipleTable" class="w-100">
                <bs-table-column prop="serverId" label="ServerId" align="center"></bs-table-column>
                <bs-table-column prop="title" label="หัวข้อ" align="center"></bs-table-column>
                <bs-table-column prop="submitter" label="ผู้ส่ง" align="center"></bs-table-column>
                <bs-table-column prop="createdAt" label="เวลาส่ง" align="center"></bs-table-column>
                <bs-table-column prop="type" label="ประเภท" align="center"></bs-table-column>
                <bs-table-column prop="status" label="สถานะ" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button type="text" @click="handleChange(scope.$index,scope.row)">แก้ไข</bs-button>
                        <bs-button type="text" @click="handleDelete(scope.$index,scope.row)">ลบ</bs-button>
                    </template>
                </bs-table-column>
            </bs-table>
            <!-- <div class="pagination">
                <bs-pagination @current-change="handleCurrentChange" layout="prev, pager, next" :total="1000">
                </bs-pagination>
            </div> -->
        </div>
        <!-- 弹窗 -->
        <bs-dialog :title="dialogTitle" v-model:visible="dialogVisible" width="35%" center :close-on-click-modal="false">
            <div class="del-dialog-cnt" v-if="this.dialogType === 'delete'">{{ dialogInfo }}</div>
            <bs-form :model="form" label-width="120px" v-if="this.dialogType === 'add' || this.dialogType === 'change'">
                <bs-form-item label="serverId">
                    <bs-select filterable v-model="form.serverId" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                        <bs-option v-if="selectedServer" :value="selectedServer" :label="`เซิร์ฟเวอร์ ${selectedServer}`"></bs-option>
                        <bs-option key="all" label="all servers" value="0"></bs-option>
                        <bs-option
                            v-if="form.serverId && form.serverId !== selectedServer && form.serverId !== '0'"
                            :value="form.serverId"
                            :label="`เซิร์ฟเวอร์ ${form.serverId}`"
                        ></bs-option>
                    </bs-select>
                </bs-form-item>
                <bs-form-item label="หัวข้อ">
                    <bs-input v-model="form.title"></bs-input>
                </bs-form-item>
                <bs-form-item label="เนื้อหาประกาศ">
                    <bs-input
                        type="textarea"
                        autosize
                        placeholder="กรอกเนื้อหา"
                        v-model="form.content"
                    ></bs-input>
                </bs-form-item>
                <bs-form-item label="ประเภทประกาศ">
                    <bs-select v-model="form.type" placeholder="กรุณาเลือก">
                        <bs-option key="once" label="ครั้งเดียว" value="once"></bs-option>
                        <bs-option key="loop" label="วนซ้ำ" value="loop"></bs-option>
                    </bs-select>
                </bs-form-item>
                <bs-form-item label="เวลาที่กำหนด">
                    <bs-date-picker
                        v-model="form.startTime"
                        type="datetime"
                        placeholder="เลือกวันที่และเวลา"
                        default-time="12:00:00"
                        value-format="yyyy-MM-dd HH:mm:ss"
                    ></bs-date-picker>
                </bs-form-item>
                <bs-form-item label="เวลาสิ้นสุด">
                    <bs-date-picker
                        v-model="form.stopTime"
                        type="datetime"
                        placeholder="เลือกวันที่และเวลา"
                        default-time="12:00:00"
                        value-format="yyyy-MM-dd HH:mm:ss"
                        :disabled="form.type === 'once'"
                    ></bs-date-picker>
                </bs-form-item>
                <bs-form-item label="ช่วงเวลา (นาที)">
                    <bs-input v-model="form.intervalTime" :disabled="form.type === 'once'"></bs-input>
                </bs-form-item>
            </bs-form>
            <template #footer><div class="d-flex justify-content-end gap-2">
                <bs-button @click="dialogVisible = false">ยกเลิก</bs-button>
                <bs-button type="primary" @click="handleConfirm">ยืนยัน</bs-button>
            </div></template>
        </bs-dialog>
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
                username: getCookie('username'),
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
                if (!this.selectedServer || this.selceted_user === '' || this.selceted_state === '') {
                    BsMessage.error('กรุณากรอกเงื่อนไขการค้นหาให้ครบ');
                } else {
                    var params = {
                        serverId: this.selectedServer,
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
                this.form.serverId = this.selectedServer;
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
                        BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                    } else {
                        for (var name in params) {
                            if (!params[name]) {
                                BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                                return
                            }
                        }
                    }
                    this.$api.post('/api/broadcast/add', params)
                    .then((res) => {
                        if (res.data.result === 1) {
                            BsMessage.success('เพิ่มสำเร็จ');
                            this.dialogVisible = false;
                            this.handleSearch();
                        } else {
                            BsMessage.error('เพิ่มประกาศไม่สำเร็จ');
                        }
                    }).catch(function (err) {
                        console.log('fetch faild:' + err);
                    })
                } else if (this.dialogType === 'change') { //修改广告广播
                    let params = this.getParams (this.form.type);
                    params.id = this.form.id;
                    if (params === undefined) {
                        BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                    } else {
                        for (var name in params) {
                            if (!params[name]) {
                                BsMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                                return
                            }
                        }
                    }
                    this.$api.post('/api/broadcast/update', params)
                    .then((res) => {
                        if (res.data[0] === 1) {
                            BsMessage.success(`แก้ไขประกาศสำเร็จ`);
                            this.dialogVisible = false;
                            this.handleSearch();
                        } else {
                            BsMessage.error('แก้ไขประกาศไม่สำเร็จ');
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
                            BsMessage.success('ลบสำเร็จ');
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
