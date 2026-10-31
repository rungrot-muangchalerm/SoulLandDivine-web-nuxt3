<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-magic-stick"></i>หักทรัพยากร</el-breadcrumb-item>
                <el-breadcrumb-item>หักไอเทม</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-select filterable v-model="opt_server" :placeholder="words.tips.PleaseSelectServerID" class="mr10">
                    <el-option 
                        v-for="item in server_list" 
                        :key="item.$.id" 
                        :label="item.$.name" 
                        :value="item.$.id"
                    ></el-option>
                </el-select>
                <el-input class="mr10" placeholder="กรอก UID" v-model="opt_uid"></el-input>
                <el-select filterable v-model="opt_type" placeholder="ประเภททรัพยากร" class="mr10">
                    <el-option 
                        v-for="item in words.resource.type_list" 
                        :key="item.value" 
                        :label="item.label" 
                        :value="item.value"
                    ></el-option>
                </el-select>
                <el-input class="mr10" placeholder="รหัสทรัพยากร" v-model="opt_id"></el-input>
                <el-input class="mr10" placeholder="จำนวน" v-model="opt_num"></el-input>
                <el-button type="primary" icon="el-icon-search" @click="handleSearch()">ค้นหา</el-button>
            </div>
            <el-table :data="opt_params" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="ItemUid" label="UID ทรัพยากร" align="center"></el-table-column>
                <el-table-column prop="ItemName" label="ชื่อ" align="center"></el-table-column>
                <el-table-column prop="ItemNum" label="จำนวน" align="center"></el-table-column>
                <el-table-column prop="Year" label="ปีของวงแหวนวิญญาณ" align="center"></el-table-column>
                <el-table-column prop="MainNature" label="คุณสมบัติกระดูกวิญญาณ" align="center"></el-table-column>
                <el-table-column prop="SpecNature1" label="คุณสมบัติเสริมกระดูกวิญญาณ 1" align="center"></el-table-column>
                <el-table-column prop="SpecNature2" label="คุณสมบัติเสริมกระดูกวิญญาณ 2" align="center"></el-table-column>
                <el-table-column prop="SpecNature3" label="คุณสมบัติเสริมกระดูกวิญญาณ 3" align="center"></el-table-column>
                <el-table-column prop="SpecNature4" label="คุณสมบัติเสริมกระดูกวิญญาณ 4" align="center"></el-table-column>
                <el-table-column prop="Level" label="ระดับการเสริมพลัง" align="center"></el-table-column>
                <el-table-column label="การดำเนินการ" width="150" align="center">
                    <template slot-scope="scope">
                        <el-button type="text" style="color:red" icon="el-icon-remove-outline" @click="handleDelete(scope.$index,scope.row)">ยกเลิกการเลือก</el-button>
                        <el-button type="text" icon="el-icon-delete" @click="handleDeduct(scope.$index,scope.row)">หัก</el-button>
                    </template>
                </el-table-column>
            </el-table>
            <br>
            <el-table :data="tableData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="ItemUid" label="UID ทรัพยากร" align="center"></el-table-column>
                <el-table-column prop="ItemName" label="ชื่อ" align="center"></el-table-column>
                <el-table-column prop="ItemNum" label="จำนวน" align="center"></el-table-column>
                <el-table-column prop="Year" label="ปีของวงแหวนวิญญาณ" align="center"></el-table-column>
                <el-table-column prop="MainNature" label="คุณสมบัติกระดูกวิญญาณ" align="center"></el-table-column>
                <el-table-column prop="SpecNature1" label="คุณสมบัติเสริมกระดูกวิญญาณ 1" align="center"></el-table-column>
                <el-table-column prop="SpecNature2" label="คุณสมบัติเสริมกระดูกวิญญาณ 2" align="center"></el-table-column>
                <el-table-column prop="SpecNature3" label="คุณสมบัติเสริมกระดูกวิญญาณ 3" align="center"></el-table-column>
                <el-table-column prop="SpecNature4" label="คุณสมบัติเสริมกระดูกวิญญาณ 4" align="center"></el-table-column>
                <el-table-column prop="Level" label="ระดับการเสริมพลัง" align="center"></el-table-column>
                <el-table-column label="การดำเนินการ" width="150" align="center">
                    <template slot-scope="scope">
                        <el-button type="text" icon="el-icon-thumb" @click="handleChoose(scope.$index,scope.row)">เลือก</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie, setCookie } from '~/utils/cookies'
    import { ElMessage } from 'element-plus'
    import { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElInput, ElOption, ElSelect, ElTable, ElTableColumn } from 'element-plus'

    export default {
        components: { ElBreadcrumb, ElBreadcrumbItem, ElButton, ElInput, ElOption, ElSelect, ElTable, ElTableColumn },
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                server_list: [],
                opt_server: '',
                opt_uid: '',
                opt_type: '',
                opt_id: '',
                opt_num: '',
                opt_params: [],
                tableData: []
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
            },
            // 查询资源信息
            handleSearch () {
                let params = {
                    serverId: this.opt_server,
                    uid: this.opt_uid,
                    type: this.opt_type,
                    id: this.opt_id,
                    num: this.opt_num,
                    channel: getCookie('channel')
                }
                for (let name in params) {
                    if (!params[name]) {
                        ElMessage.error('มีช่องว่างที่ยังไม่ได้กรอก กรุณาตรวจสอบและกรอกให้ครบ!');
                        return
                    }
                }
                this.$api.post('/api/itemdelete/search', params)
                .then(res => {
                    switch (res.data) {
                        case 'nodata':
                            ElMessage.info('บัญชีนี้ไม่มีทรัพยากรดังกล่าว');
                            this.tableData = [];
                            break;
                    
                        case 'nomore':
                            ElMessage.info('ทรัพยากรในบัญชีนี้ไม่เพียงพอ');
                            this.tableData = [];
                            break;

                        default:
                            this.tableData = res.data;
                            break;
                    }
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                });
            },
            // 选择要操作的资源条目
            handleChoose (index,row) {
                this.opt_params.push(JSON.parse(JSON.stringify(row)));
            },
            // 取消选择操作的资源条目
            handleDelete (index,row) {
                this.opt_params.splice(index,1);
            },
            // 扣除资源
            handleDeduct (index,row) {
                let params = {
                    ServerId: this.opt_server,
                    UserId: this.opt_uid,
                    RewardType: row.RewardType,
                    ItemId: row.ItemId,
                    ItemUid: row.ItemUid,
                    ItemNum: row.ItemNum,
                    channel: getCookie('channel')
                }
                this.$api.post('/api/itemdelete/deduct', params)
                .then(res => {
                    if (res.data.result === 1) {
                        ElMessage.success(`หักไอเทมประเภท ${params.RewardType} รหัส ${params.ItemId} จำนวน ${params.ItemNum} ชิ้น จาก ${params.UserId} สำเร็จ`);
                        this.opt_params.splice(index,1);
                    }
                }).catch(function (err) {
                    console.log('fetch faild:' + err);
                });
            }
        }
    }
</script>

<style scoped>
    .handle-box {
        margin-bottom: 20px;
    }

    .mr10 {
        width: 15%;
    }

</style>
