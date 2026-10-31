<template>
    <div class="table">
        <div class="mb-3">
            <bs-breadcrumb separator="/">
                <bs-breadcrumb-item><i class="magic-stick"></i>หักทรัพยากร</bs-breadcrumb-item>
                <bs-breadcrumb-item>หักไอเทม</bs-breadcrumb-item>
            </bs-breadcrumb>
        </div>
        <div class="container">
            <div class="d-flex flex-wrap align-items-end gap-2 mb-3">
                <bs-select filterable v-model="opt_server" :placeholder="words.tips.PleaseSelectServerID" class="mr10" @change="handleServerChange">
                    <bs-option 
                        v-for="item in server_list" 
                        :key="item.id" 
                        :label="item.name" 
                        :value="item.id"
                    ></bs-option>
                </bs-select>
            </div>
            <div v-if="loading" class="alert alert-info">กำลังโหลดรายการไอเทม...</div>
            <div v-else class="small text-body-secondary mb-2">
                {{ opt_server ? `รายการไอเทมทั้งหมด ${total} รายการ` : 'เลือกเซิร์ฟเวอร์เพื่อแสดงรายการไอเทม' }}
            </div>
            <bs-table :data="opt_params" border row-key="selectionKey" class="w-100">
                <bs-table-column prop="UserId" label="UID ผู้เล่น" align="center"></bs-table-column>
                <bs-table-column prop="CharacterName" label="ตัวละคร" align="center"></bs-table-column>
                <bs-table-column prop="ItemCategory" label="ประเภททรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemUid" label="UID ทรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemId" label="รหัสไอเทม" align="center"></bs-table-column>
                <bs-table-column prop="ItemNum" label="จำนวน" align="center"></bs-table-column>
                <bs-table-column prop="Year" label="ปีของวงแหวนวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="MainNature" label="คุณสมบัติกระดูกวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature1" label="คุณสมบัติเสริมกระดูกวิญญาณ 1" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature2" label="คุณสมบัติเสริมกระดูกวิญญาณ 2" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature3" label="คุณสมบัติเสริมกระดูกวิญญาณ 3" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature4" label="คุณสมบัติเสริมกระดูกวิญญาณ 4" align="center"></bs-table-column>
                <bs-table-column prop="Level" label="ระดับการเสริมพลัง" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button type="text" @click="handleDelete(scope.$index,scope.row)" class="text-danger">ยกเลิกการเลือก</bs-button>
                        <bs-button type="text" @click="handleDeduct(scope.$index,scope.row)">หัก</bs-button>
                    </template>
                </bs-table-column>
            </bs-table>
            <br>
            <bs-table :data="tableData" border row-key="selectionKey" class="w-100">
                <bs-table-column prop="UserId" label="UID ผู้เล่น" align="center"></bs-table-column>
                <bs-table-column prop="AccountName" label="บัญชี" align="center"></bs-table-column>
                <bs-table-column prop="CharacterName" label="ตัวละคร" align="center"></bs-table-column>
                <bs-table-column prop="ItemCategory" label="ประเภททรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemUid" label="UID ทรัพยากร" align="center"></bs-table-column>
                <bs-table-column prop="ItemId" label="รหัสไอเทม" align="center"></bs-table-column>
                <bs-table-column prop="ItemNum" label="จำนวน" align="center"></bs-table-column>
                <bs-table-column prop="Year" label="ปีของวงแหวนวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="MainNature" label="คุณสมบัติกระดูกวิญญาณ" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature1" label="คุณสมบัติเสริมกระดูกวิญญาณ 1" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature2" label="คุณสมบัติเสริมกระดูกวิญญาณ 2" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature3" label="คุณสมบัติเสริมกระดูกวิญญาณ 3" align="center"></bs-table-column>
                <bs-table-column prop="SpecNature4" label="คุณสมบัติเสริมกระดูกวิญญาณ 4" align="center"></bs-table-column>
                <bs-table-column prop="Level" label="ระดับการเสริมพลัง" align="center"></bs-table-column>
                <bs-table-column label="การดำเนินการ" width="150" align="center">
                    <template #default="scope">
                        <bs-button v-if="scope.row.CanDeduct" type="text" @click="handleChoose(scope.$index,scope.row)">เลือกหัก</bs-button>
                        <span v-else>ดูอย่างเดียว</span>
                    </template>
                </bs-table-column>
            </bs-table>
            <bs-pagination
                v-if="total > 0"
                :current-page="page"
                :page-size="pageSize"
                :total="total"
                layout="prev, pager, next, total"
                @current-change="handlePageChange"
            ></bs-pagination>
        </div>
    </div>
</template>

<script>
    import { createAdminWords } from '~/utils/admin-state'
    import { getCookie } from '~/utils/cookies'
import { BsMessage } from '~/utils/bootstrap-message'

    export default {
        
        setup () { return { words: createAdminWords() } },
        data () {
            return {
                server_list: [],
                opt_server: '',
                opt_params: [],
                tableData: [],
                page: 1,
                pageSize: 50,
                total: 0,
                loading: false
            }
        },
        mounted () {
            this.getBaseInfo();
        },
        methods: {
            getBaseInfo () {
                this.$api.post('/api/characters/servers', { channel: getCookie('channel') })
                .then((res) => {
                    this.server_list = res.data;
                }).catch((err) => {
                    BsMessage.error(err?.data?.statusMessage || 'โหลดรายชื่อเซิร์ฟเวอร์ไม่สำเร็จ');
                });
            },
            handleServerChange () {
                this.page = 1;
                this.opt_params = [];
                this.loadInventory();
            },
            handlePageChange (page) {
                this.page = page;
                this.loadInventory();
            },
            loadInventory () {
                if (!this.opt_server) {
                    this.tableData = [];
                    this.total = 0;
                    return;
                }
                this.loading = true;
                this.$api.post('/api/itemdelete/listServer', {
                    serverId: this.opt_server,
                    page: this.page,
                    channel: getCookie('channel')
                }).then((res) => {
                    this.tableData = res.data.data.map((item, index) => ({
                        ...item,
                        selectionKey: `${item.UserId}:${item.RewardType}:${item.ItemUid}:${index}`
                    }));
                    this.page = res.data.page;
                    this.pageSize = res.data.pageSize;
                    this.total = res.data.total;
                }).catch((err) => {
                    BsMessage.error(err?.data?.statusMessage || 'โหลดรายการไอเทมไม่สำเร็จ');
                }).finally(() => {
                    this.loading = false;
                });
            },
            handleChoose (index, row) {
                if (!row.CanDeduct) {
                    BsMessage.info('ข้อมูลประเภทนี้แสดงได้อย่างเดียว ยังไม่รองรับการหักจากหน้านี้');
                    return;
                }
                this.opt_params.push({ ...row });
            },
            handleDelete (index,row) {
                this.opt_params.splice(index,1);
            },
            handleDeduct (index,row) {
                let params = {
                    ServerId: this.opt_server,
                    UserId: row.UserId,
                    RewardType: row.RewardType,
                    ItemId: row.ItemId,
                    ItemUid: row.ItemUid,
                    ItemNum: row.ItemNum,
                    channel: getCookie('channel')
                }
                this.$api.post('/api/itemdelete/deduct', params)
                .then(res => {
                    if (res.data.result === 1) {
                        BsMessage.success(`หักไอเทมประเภท ${params.RewardType} รหัส ${params.ItemId} จำนวน ${params.ItemNum} ชิ้น จาก ${params.UserId} สำเร็จ`);
                        this.opt_params.splice(index,1);
                        this.tableData = this.tableData.filter(item => item.selectionKey !== row.selectionKey);
                        this.total = Math.max(0, this.total - 1);
                        if (!this.tableData.length && this.page > 1) {
                            this.page -= 1;
                        }
                        this.loadInventory();
                    }
                }).catch((err) => {
                    BsMessage.error(err?.data?.statusMessage || 'หักไอเทมไม่สำเร็จ');
                });
            }
        }
    }
</script>


