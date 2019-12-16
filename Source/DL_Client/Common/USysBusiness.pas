{*******************************************************************************
  ����: dmzn@163.com 2017-09-27
  ����: ϵͳҵ����
*******************************************************************************}
unit USysBusiness;

{$I Link.inc}
interface

uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels, UMgrCamera, UBase64, USysConst,
  USysDB, USysLoger, StrUtils;

type
  TLadingStockItem = record
    FID: string;         //���
    FType: string;       //����
    FName: string;       //����
    FParam: string;      //��չ
  end;

  TDynamicStockItemArray = array of TLadingStockItem;
  //ϵͳ���õ�Ʒ���б�

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FWeight   : Integer;     //����
    FValid    : Boolean;     //�Ƿ���Ч
    FPrinterOK: Boolean;     //�����
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //���ƺ�
    FLine     : string;      //ͨ��
    FBill     : string;      //�����
    FValue    : Double;      //�����
    FDai      : Integer;     //����
    FTotal    : Integer;     //����
    FInFact   : Boolean;     //�Ƿ����
    FIsRun    : Boolean;     //�Ƿ�����    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  PSalePlanItem = ^TSalePlanItem;
  TSalePlanItem = record
    FOrderNo: string;        //������     
    FInterID: string;        //������
    FEntryID: string;        //������
    FStockID: string;        //���ϱ��
    FStockName: string;      //��������

    FTruck: string;          //���ƺ���
    FValue: Double;          //������
    FSelected: Boolean;      //״̬
  end;
  TSalePlanItems = array of TSalePlanItem;
  
//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function WorkPCHasPopedom: Boolean;
//��֤�����Ƿ�����Ȩ
function GetSysValidDate: Integer;
//��ȡϵͳ��Ч��
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean = True): string;
//��ȡ���б��
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//����Ʒ���б�
function GetCardUsed(const nCard: string): string;
//��ȡ��Ƭ����
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//��ȡϵͳ�ֵ���
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡҵ��Ա�б�
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡ�ͻ��б�

{$IFDEF UseWXERP}
function GetLoginToken(const username,password: string): Boolean;
//���ŵ�¼
function SyncWXDept:Boolean;
//ͬ�����Ų�����Ϣ
function SyncWXPersonal:Boolean;
//ͬ��������Ա��Ϣ
function SyncWXCusPro:Boolean;
//ͬ��������Ա��Ϣ
function SyncWXStockType:Boolean;
//ͬ�����������Ϣ
function SyncWXStockInfo:Boolean;
//ͬ�����������Ϣ
function SyncWXOrderInfo(const nStr: string):string;
//ͬ���ɹ�������Ϣ
function SyncWXSaleInfo(const nStr: string):Boolean;
//ͬ�����۶�����Ϣ
function SyncWXPoundKW(const nID: string): Boolean;
//ͬ����������
function SyncWXPoundDel(const nID: string): Boolean;
//ͬ������ɾ��
{$ENDIF}

//����ʶ��
function VeriFyTruckLicense(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;

function VerifyFQSumValue: Boolean;
//�Ƿ�У���ǩ��
function SaveBill(const nBillData: string): string;
//���潻����
function DeleteBill(const nBill: string): Boolean;
//ɾ��������
function PostBill(const nBill: string): Boolean;
//����������
function ReserveBill(const nBill: string): Boolean;
//����������
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
//�����������
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
//����������
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
//Ϊ����������ſ�
function SaveBillLSCard(const nCard,nTruck: string): Boolean;
//���������۴ſ�
function SaveBillCard(const nBill, nCard: string): Boolean;
//���潻�����ſ�
function LogoutBillCard(const nCard: string): Boolean;
//ע��ָ���ſ�
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
//�󶨳������ӱ�ǩ

function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ľ������б�
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
//���뵥����Ϣ���б�
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil;const nLogin: Integer = -1): Boolean;
//����ָ����λ�Ľ�����

function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
//��ȡָ���������ѳ�Ƥ����Ϣ
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems;const nLogin: Integer = -1): Boolean;
//���泵��������¼
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
//��ȡָ����վ��ͷ�ϵĿ���
procedure CapturePicture(const nTunnel: PPTTunnelItem;
                         const nLogin: Integer; nList: TStrings);
//ץ��ָ��ͨ��
function GetTruckNO(const nTruck: WideString; const nLong: Integer=12): string;
function GetValue(const nValue: Double): string;
//��ʾ��ʽ��

function GetTruckEmptyValue(const nTruck, nType: string): Double;
//��ȡ����Ƥ��
function GetTruckLastTime(const nTruck: string): Integer;
//���һ�ι���ʱ��
function GetTruckLastTimeEx(const nTruck: string; var nLast: Integer): Boolean;
//��ȡ��������
function IsStrictSanValue: Boolean;
//�ж��Ƿ��ϸ�ִ��ɢװ��ֹ����

procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string = '');
//��ȡ��Χ
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom: string = sFlag_DepBangFang ;
 const nSolution: string = sFlag_Solution_YN;
 const nDepartmen: string = sFlag_DepDaTing;
 const nReset: Boolean = False; const nMemo: string = ''): Boolean;
//��Ӵ����������¼
function VerifyManualEventRecord(const nEID: string; var nHint: string;
 const nWant: string = sFlag_Yes): Boolean;
//����¼��Ƿ�ͨ������

function IsTunnelOK(const nTunnel: string): Boolean;
//��ѯͨ����դ�Ƿ�����
procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
//����ͨ�����̵ƿ���
procedure ProberShowTxt(const nTunnel, nText: string);
//���췢��С��
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
//���м����������

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//��ͣ�����
function ChangeDispatchMode(const nMode: Byte): Boolean;
//�л�����ģʽ
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
//�������򿪵�բ

function GetHYMaxValue: Double;
function GetHYValueByStockNo(const nNo: string): Double;
//��ȡ���鵥�ѿ���

function getCustomerInfo(const nData: string): string;
//��ȡ�ͻ�ע����Ϣ
function get_Bindfunc(const nData: string): string;
//�ͻ���΢���˺Ű�
function send_event_msg(const nData: string): string;
//������Ϣ
function edit_shopclients(const nData: string): string;
//�����̳��û�
function edit_shopgoods(const nData: string): string;
//�����Ʒ
function get_shoporders(const nData: string): string;
//��ȡ������Ϣ
function complete_shoporders(const nData: string): string;
//���¶���״̬
procedure SaveWebOrderMsg(const nLID, nWebOrderID: string);
//����������Ϣ

//------------------------------------------------------------------------------
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//��ӡ�����
function PrintCNSReport(nBill: string; const nAsk: Boolean): Boolean;
//��ӡ������ŵ��
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
//��ӡ��
function PrintPoundOtherReport(const nPound: string; nAsk: Boolean): Boolean;
//��ӡ��ʱ���ع�����
function PrintHuaYanReport(const nHID: string; const nAsk: Boolean): Boolean;
function PrintHuaYanReportEx(const nBill: string; var nHint: string): Boolean;
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
//���鵥,�ϸ�֤
function PrintBillHD(const nBatcode: string; const nAsk: Boolean): Boolean;
//��ӡ���ۻش�

function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
//Ϊ�ɹ�������ſ�

function LogoutOrderCard(const nCard: string;const nNeiDao:string=''): Boolean;
//ע��ָ���ſ�

function DeleteOrder(const nOrder: string): Boolean;
//ɾ���ɹ���

function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
//�޸ĳ��ƺ�

function PrintOrderReport(const nOrder: string;  const nAsk: Boolean): Boolean;
//��ӡ�ɹ���
function IFHasOrder(const nTruck: string): Boolean;
//�����Ƿ����δ��ɲɹ���

function SaveOrder(const nOrderData: string): string;

function SaveOrderCard(const nOrder, nCard: string): Boolean;
//����ɹ����ſ�

//��ȡԤ��Ƥ�س���Ԥ����Ϣ
function getPrePInfo(const nTruck:string;var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime):Boolean;
function GetLastPInfo(const nID:string;var nPValue: Double; var nPMan: string;
  var nPTime: TDateTime):Boolean;

function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ĳɹ����б�
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil;const nLogin: Integer = -1): Boolean;
//����ָ����λ�Ĳɹ���

procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);

function SyncPProvider(const nProID: string): Boolean;
//ͬ��ERP�ɹ���Ӧ��
function SyncPMaterail(const nMID: string): Boolean;
//ͬ��ERP�ɹ�����
function GetHhOrderPlan(const nStr: string): string;
//��ȡERP�ɹ������ƻ�
function GetHhSaleWTTruck(const nStr: string): string;
//��ȡERPί�г���
function SyncHhOrderData(const nDID: string): Boolean;
//ͬ��ERP�ɹ�����
function GetHhNeiDaoOrderPlan(const nStr: string): string;
//��ȡERP�ɹ��ڵ������ƻ�
function SyncHhNdOrderData(const nDID: string): Boolean;
//ͬ��ERP�ڵ��ɹ�����
function SyncHhOtherOrderData(const nDID: string): Boolean;
//ͬ��ERP��Ʒ�����ɹ�����
function GetCardGInvalid: Boolean;
//���ڿ��Ƿ�ʧЧ
function GetShipName(const nStockName :string): string;
//Desc: ��ȡ��ͷ����(�ϴ�ͬƷ��)
function GetLastPID(const nOID :string): string;
//Desc: ��ȡ���°�����
function GetHhSalePlan(const nFactoryName: string): Boolean;
//��ȡERP���ۼƻ�
function SyncSMaterail(const nMID: string): Boolean;
//��ȡERP��������
function SyncSCustomer(const nCusID: string): Boolean;
//Desc: ͬ��ERP���ۿͻ�
function SyncHhSaleDetail(const nDID: string): Boolean;
//Desc: ͬ��ERP������ϸ
procedure SaveTruckPrePValue(const nTruck, nValue: string);
//����Ԥ��Ƥ��
function GetPrePValueSet: Double;
//��ȡϵͳ�趨Ƥ��
function GetMinNetValue: Double;
//��ȡ���۾�����ֵ
function SaveTruckPrePicture(const nTruck: string;const nTunnel: PPTTunnelItem;
                             const nLogin: Integer = -1): Boolean;
//����nTruck��Ԥ��Ƥ����Ƭ
function InitCapture(const nTunnel: PPTTunnelItem; var nLogin: Integer): Boolean;
//��ʼ��ץ��(���вİ���ץ�ĳ��ֿͻ��˱���,��Ϊ�򿪳��ؽ�����г�ʼ��)
function FreeCapture(nLogin: Integer): Boolean;
//�ͷ�ץ��
procedure UpdateTruckStatus(const nID: string);
//�޸ĳ���״̬
function GetMaxMValue(const nType, nID, nCusID, nCusName, nTruck: string): Double;
//��ȡë����ֵ
function GetSaleOrderRestValue(const nID: string): Double;
//��ȡ��������
function IsTruckCanPound(const nItem: TLadingBillItem): Boolean;
//��ʱ���۶���ҵ�����Ƿ�����ϰ�
function GetBatchCode(const nStockNo,nCusName: string; nValue: Double): string;
//��ȡ���κ�
function GetStockNo(const nStockName,nStockType: string): string;
//��ȡ���ϱ��
procedure SaveWebOrderDelMsg(const nLID, nBillType: string);
//����������Ϣ
function GetSaleOrderDoneValue(const nOID, nCusName, nStockName: string): string;
//��ѯ����ҵ�������
function GetSaleOrderFreezeValue(const nOID: string): string;
//��ѯ����ҵ�񶳽���
function CheckTruckCard(const nTruck: string; var nLID: string): Boolean;
//��鳵���Ƿ����δע���ſ��������(�������ҵ��)
function IsOtherOrder(const nItem: TLadingBillItem): Boolean;
 //����Ƿ�Ϊ��ʱ����
function IsTruckTimeOut(const nLID: string): Boolean;
//��֤�����Ƿ������ʱ
function GetEventDept: string;
//��ȡ�����¼����Ͳ���

//=====================================================================
function SyncPProviderWSDL(const nProID: string): Boolean;
//ͬ��ERP�ɹ���Ӧ��
function GetHhOrderPlanWSDL(const nStr: string): string;
//��ȡERP�ɹ������ƻ�
function GetHhSaleWTTruckWSDL(const nStr: string): string;
//��ȡERPί�г���
function SyncHhOrderDataWSDL(const nDID: string): Boolean;
//ͬ��ERP�ɹ�����
function GetHhNeiDaoOrderPlanWSDL(const nStr: string): string;
//��ȡERP�ɹ��ڵ������ƻ�
function SyncHhNdOrderDataWSDL(const nDID: string): Boolean;
//ͬ��ERP�ڵ��ɹ�����
function SyncHhOtherOrderDataWSDL(const nDID: string): Boolean;
//ͬ��ERP��Ʒ�����ɹ�����
function GetHhSalePlanWSDL(const nWhere, nFactoryName: string): Boolean;
//��ȡERP���ۼƻ�
function SyncSMaterailWSDL(const nMID: string): Boolean;
//��ȡERP��������
function SyncSCustomerWSDL(const nCusID: string): Boolean;
//Desc: ͬ��ERP���ۿͻ�
function SyncHhSaleDetailWSDL(const nDID: string): Boolean;
//Desc: ͬ��ERP������ϸ
function GetHhSaleWareNumberWSDL(const nOrder, nValue: string;
                                 var nHint: string): string;
//Desc: ��ȡ���κ�
function PoundVerifyHhSalePlanWSDL(const nLID: string; nValue: Double;
                                   nPriceDate:string; var nHint: string): Boolean;
//===================================================================
function GetCusID(const nCusName :string): string;
function IsMulMaoStock(const nStockNo :string): Boolean;
function IsAsternStock(const nStockName :string): Boolean;
function UpdateKCValue(const nLID :string): Boolean;
function GetOrderID(const nOID :string): string;
function VerifyPurOrder(const nID: string; var nHint: string): Boolean;
function GetMaxLadeValue(const nTruck: string): Double;
function KDVerifyHhSalePlanWSDL(const nPrice, nValue: Double;
                                   nPriceDate:string;
                                 var nHint: string): Boolean;
function VeriFySnapTruck(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
function ReadPoundReaderInfo(const nReader: string; var nDept: string): string;
//��ȡnReader��λ������
procedure RemoteSnapDisPlay(const nPost, nText, nSucc: string);

function JudgePurOrder(const nID: string; var nHint: string): Boolean;
//У��ԭ���϶���
function SaveSnapStatus(const nBill: TLadingBillItem; nStatus: string): Boolean;
procedure UpdateMultMStatus(const nID: string);
implementation

//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//------------------------------------------------------------------------------
//Desc: ����nHintΪ�׶��ĸ�ʽ
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '��.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//Desc: ��֤�����Ƿ�����Ȩ����ϵͳ
function WorkPCHasPopedom: Boolean;
begin
  Result := gSysParam.FSerialID <> '';
  if not Result then
  begin
    ShowDlg('�ù�����Ҫ����Ȩ��,�������Ա����.', sHint);
  end;
end;

//Date: 2017-09-27
//Parm: ����;����;����;���
//Desc: �����м���ϵ�ҵ���������
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-09-27
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-09-27
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrder(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessPurchaseOrder);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-09-27
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-10-26
//Parm: ����;����;����;�����ַ;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessWechat(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerWebChatData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerWebChatData;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //close hint param
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessWebchat);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-10-26
//Parm: ����;����;����;�����ַ;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHHJY(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerHHJYData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerHHJYData;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //close hint param

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessHHJY);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017-09-27
//Parm: ����;����;ʹ�����ڱ���ģʽ
//Desc: ����nGroup.nObject���ɴ��б��
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;   
end;

//Desc: ��ȡϵͳ��Ч��
function GetSysValidDate: Integer;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
       Result := StrToInt(nOut.FData)
  else Result := 0;
end;

function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

//Desc: ��ȡ��ǰϵͳ���õ�ˮ��Ʒ���б�
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_Value,D_Memo,D_ParamB From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_StockItem)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    SetLength(nItems, RecordCount);
    if RecordCount > 0 then
    begin
      nIdx := 0;
      First;

      while not Eof do
      begin
        nItems[nIdx].FType := FieldByName('D_Memo').AsString;
        nItems[nIdx].FName := FieldByName('D_Value').AsString;
        nItems[nIdx].FID := FieldByName('D_ParamB').AsString;

        Next;
        Inc(nIdx);
      end;
    end;
  end;

  Result := Length(nItems) > 0;
end;

//Date: 2017-10-01
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

//Desc: ��ȡҵ��Ա�б�nList��,������������
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
          'Where IsNull(S_InValid, '''')<>''%s'' %s Order By S_PY';
  nStr := Format(nStr, [sTable_Salesman, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['S_ID']));
  
  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: ��ȡ�ͻ��б�nList��,������������
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'C_ID=Select C_ID,C_Name From %s ' +
          'Where IsNull(C_XuNi, '''')<>''%s'' %s Order By C_PY';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.');

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

{$IFDEF UseWXERP}
function GetLoginToken(const username,password: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetLoginToken, username, password, '', @nOut);
end;

function SyncWXDept:Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetDepotInfo, '', '', '', @nOut);
end;

function SyncWXPersonal:Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetUserInfo, '', '','', @nOut);
end;

function SyncWXCusPro:Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetCusProInfo, '', '','', @nOut);
end;

function SyncWXStockType:Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetStockType, '', '', '', @nOut);
end;

function SyncWXStockInfo:Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetStockInfo, '', '','', @nOut);
end;

function SyncWXOrderInfo(const nStr: string):string;
var nOut: TWorkerHHJYData;
begin
  if CallBusinessHHJY(cBC_GetOrderInfo, nStr, '','', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

function SyncWXSaleInfo(const nStr: string):Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetSaleInfo, nStr, '','', @nOut,False);
end;

function SyncWXPoundKW(const nID: string): Boolean;
var nOut: TWorkerHHJYData;
    nStr: string;
    nList: TStrings;
begin
  Result := False;
  nList := TStringList.Create;

  try
    nStr := 'Select P_ID, P_TYPE  From %s Where P_ID = ''%s'' ';
    nStr := Format(nStr, [sTable_PoundLog, nID]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nList.Values['P_ID']      := Fields[0].AsString;
      nList.Values['P_TYPE']    := Fields[1].AsString;
      nList.Values['P_Status']  := '0';

      nStr   := PackerEncodeStr(nList.Text);
      Result := CallBusinessHHJY(cBC_GetPoundKW, nStr, '', '', @nOut, False);
    end;
  finally
    nList.Free;
  end;
end;

function SyncWXPoundDel(const nID: string): Boolean;
var nOut: TWorkerHHJYData;
    nStr: string;
    nList: TStrings;
begin
  Result := False;
  nList := TStringList.Create;

  try
    nStr := 'Select P_ID, P_TYPE  From %s Where P_BILL = ''%s'' ';
    nStr := Format(nStr, [sTable_PoundLog, nID]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nList.Values['P_ID']      := Fields[0].AsString;
      nList.Values['P_TYPE']    := Fields[1].AsString;
      nList.Values['P_Status']  := '1';

      nStr   := PackerEncodeStr(nList.Text);
      Result := CallBusinessHHJY(cBC_GetPoundKW, nStr, '', '', @nOut, False);
    end;
  finally
    nList.Free;
  end;
end;

{$ENDIF}

//------------------------------------------------------------------------------
//Date: 2017-09-27
//Parm: ��¼��ʶ;���ƺ�;ͼƬ�ļ�
//Desc: ��nFile�������ݿ�
procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
begin
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
    //xxxxx

    if FDM.ExecuteSQL(nStr) < 1 then Exit;
    nRID := FDM.GetFieldMax(sTable_Picture, 'R_ID');

    nStr := 'Select P_Picture From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_Picture, nRID]);
    FDM.SaveDBImage(FDM.QueryTemp(nStr), 'P_Picture', nFile);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: ����ͼƬ·��
function MakePicName: string;
begin
  while True do
  begin
    Result := gSysParam.FPicPath + IntToStr(gSysParam.FPicBase) + '.jpg';
    if not FileExists(Result) then
    begin
      Inc(gSysParam.FPicBase);
      Exit;
    end;

    DeleteFile(Result);
    if FileExists(Result) then Inc(gSysParam.FPicBase)
  end;
end;

//Date: 2017-09-27
//Parm: ͨ��;�б�
//Desc: ץ��nTunnel��ͼ��
procedure CapturePicture(const nTunnel: PPTTunnelItem;
                         const nLogin: Integer; nList: TStrings);
const
  cRetry = 2;
  //���Դ���
var nStr: string;
    nIdx,nInt: Integer;
    nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera
  if nLogin <= -1 then Exit;

  WriteLog(nTunneL.FID + '��ʼץ��');
  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  try

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        gCameraNetSDKMgr.NET_DVR_CaptureJPEGPicture(nLogin,
                                   nTunnel.FCameraTunnels[nIdx],
                                   nPic, nStr);
        //capture pic

        nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;

        if nErr = 0 then
        begin
          WriteLog('ͨ��'+IntToStr(nTunnel.FCameraTunnels[nIdx])+'ץ�ĳɹ�');
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := 'ץ��ͼ��[ %s.%d ]ʧ��,������: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  except
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-10-17
//Parm: ���ƺ�;��������
//Desc: ��nTruck����Ϊ����ΪnLen���ַ���
function GetTruckNO(const nTruck: WideString; const nLong: Integer): string;
var nStr: string;
    nIdx,nLen,nPos: Integer;
begin
  nPos := 0;
  nLen := 0;

  for nIdx:=Length(nTruck) downto 1 do
  begin
    nStr := nTruck[nIdx];
    nLen := nLen + Length(nStr);

    if nLen >= nLong then Break;
    nPos := nIdx;
  end;

  Result := Copy(nTruck, nPos, Length(nTruck));
  nIdx := nLong - Length(Result);
  Result := Result + StringOfChar(' ', nIdx);
end;

function GetValue(const nValue: Double): string;
var nStr: string;
begin
  nStr := Format('      %.2f', [nValue]);
  Result := Copy(nStr, Length(nStr) - 6 + 1, 6);
end;

//Date: 2017-09-27
//Parm: ��װ�������;Ʊ��;��վ��
//Desc: ����nVal����Χ
procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string);
var nStr: string;
begin
  nWCValZ := 0;
  nWCValF := 0;
  if nVal <= 0 then Exit;

  nStr := 'Select * From %s Where P_Start<=%.2f and P_End>%.2f';
  nStr := Format(nStr, [sTable_PoundDaiWC, nVal, nVal]);

  if Length(nStation) > 0 then
    nStr := nStr + ' And P_Station=''' + nStation + '''';
  //xxxxx

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('P_Percent').AsString = sFlag_Yes then 
    begin
      nWCValZ := nVal * 1000 * FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := nVal * 1000 * FieldByName('P_DaiWuChaF').AsFloat;
      //�������������
    end else
    begin     
      nWCValZ := FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := FieldByName('P_DaiWuChaF').AsFloat;
      //���̶�ֵ�������
    end;
  end;
end;

//Date: 2017-09-27
//Parm: ��������
//Desc: ����쳣�¼�����
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom,nSolution,nDepartmen: string;
 const nReset: Boolean; const nMemo: string): Boolean;
var nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  if Trim(nSolution) = '' then
  begin
    WriteLog('��ѡ������.');
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '�¼���¼:[ %s ]�Ѵ���';
    WriteLog(Format(nStr, [nEID]));

    if not nReset then Exit;
    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          SF('E_Result', 'Null', sfVal),
          
          SF('E_Event', nEvent),
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx

  FDM.ExecuteSQL(nStr);
  Result := True;
end;

//Date: 2017-09-27
//Parm: �¼�ID;Ԥ�ڽ��;���󷵻�
//Desc: �ж��¼��Ƿ���
function VerifyManualEventRecord(const nEID: string; var nHint: string;
 const nWant: string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select E_Result, E_Event From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
//      nHint := FieldByName('E_Event').AsString;
      Exit;
    end;

    if nStr <> nWant then
    begin
      nHint := '����ϵ����Ա������Ʊ����';
      Exit;
    end;

    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-09-27
//Parm: ͨ����
//Desc: ��ѯnTunnel�Ĺ�դ״̬�Ƿ�����
function IsTunnelOK(const nTunnel: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHardware(cBC_IsTunnelOK, nTunnel, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nOpen then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_TunnelOC, nTunnel, nStr, @nOut);
end;

procedure ProberShowTxt(const nTunnel, nText: string);
var nOut: TWorkerBusinessCommand;
begin
  CallBusinessHardware(cBC_ShowTxt, nTunnel, nText, @nOut);
end;

//Date: 2017-09-27
//Parm: �ı�;������;����
//Desc: ��nCard����nContentģʽ��nText�ı�.
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Card=' + nCard + #13#10 +
          'Content=' + nContent + #13#10 + 'Truck=' + nText;
  //xxxxxx

  Result := CallBusinessHardware(cBC_PlayVoice, nStr, '', @nOut);
  if not Result then
    WriteLog(nOut.FBase.FErrDesc);
  //xxxxx
end;

//Date: 2017-09-27
//Parm: ���ƺ�
//Desc: ��ȡnTruck�ĳ�Ƥ��¼
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2017-09-27
//Parm: ��������
//Desc: ����nData��������
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  nList := TStringList.Create;
  try
    try
      CapturePicture(nTunnel, nLogin, nList);
      //capture file
    except
      on e: Exception do
      begin
        WriteLog('ץ��ʧ��:'+e.Message);
      end;
    end;

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//Date: 2017-09-27
//Parm: ͨ����
//Desc: ��ȡnTunnel��ͷ�ϵĿ���
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //����

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, '', @nOut) then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-09-27
//Parm: ͨ��;����
//Desc: ��ȡ������������
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;
      FPrinterOK:= Values['Printer'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2017-09-27
//Parm: ͨ����;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nEnable then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_PrinterEnable, nTunnel, nStr, @nOut);
end;

//Date: 2017-09-27
//Parm: ����ģʽ
//Desc: �л�ϵͳ����ģʽΪnMode
function ChangeDispatchMode(const nMode: Byte): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ChangeDispatchMode, IntToStr(nMode), '',
            @nOut);
  //xxxxx
end;

//Date: 2017-09-27
//Parm: ��������
//Desc: ���潻����,���ؽ��������б�
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017-09-27
//Parm: ��������
//Desc: ɾ��nBill����
function DeleteBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_DeleteBill, nBill, '', @nOut);
end;

//Date: 2017-10-10
//Parm: ��������
//Desc: ����nBill����
function PostBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_PostBill, nBill, '', @nOut);
end;

//Date: 2017-10-14
//Parm: ��������
//Desc: ����nBill����
function ReserveBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ReverseBill, nBill, '', @nOut);
end;

//Date: 2017-09-27
//Parm: ������;�³���
//Desc: �޸�nBill�ĳ���ΪnTruck.
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ModifyBillTruck, nBill, nTruck, @nOut);
end;

//Date: 2017-09-27
//Parm: ������;ֽ��
//Desc: ��nBill������nNewZK�Ŀͻ�
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaleAdjust, nBill, nNewZK, @nOut);
end;

//Date: 2017-09-27
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Sale;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

function VerifyTruckLicense(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
var nStr, nDept: string;
    nNeedManu, nUpdate: Boolean;
    nTruck, nEvent, nPicName: string;
    nLastTime: TDateTime;
begin
  Result := False;
  nPos := sFlag_DepBangFang;
  nNeedManu := False;
  nDept := '';
  nTruck := nBill.Ftruck;

  nStr := ' Select D_Value From %s Where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_EnableTruck]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;

      if nNeedManu then
      begin
        nMsg := '������[ %s ]����ʶ��������.';
        nMsg := Format(nMsg, [nReader]);
      end
      else
      begin
        nMsg := '������[ %s ]����ʶ���ѹر�.';
        nMsg := Format(nMsg, [nReader]);
        Result := True;
        Exit;
      end;
    end
    else
    begin
      Result := True;
      nMsg := '������[ %s ]δ���ó���ʶ��.';
      nMsg := Format(nMsg, [nReader]);
      Exit;
    end;
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;

      if nNeedManu then
      begin
        nMsg := '������[ %s ]�󶨸�λ[ %s ]��Ԥ����:�˹���Ԥ������.';
        nMsg := Format(nMsg, [nReader, nPos]);
      end
      else
      begin
        nMsg := '������[ %s ]�󶨸�λ[ %s ]��Ԥ����:�˹���Ԥ�ѹر�.';
        nMsg := Format(nMsg, [nReader, nPos]);
        Result := True;
        Exit;
      end;
    end
    else
    begin
      Result := True;
      nMsg := '������[ %s ]�󶨸�λ[ %s ]δ���ø�Ԥ����,�޷����г���ʶ��.';
      nMsg := Format(nMsg, [nReader, nPos]);
      Exit;
    end;
  end;

  nStr := 'Select T_LastTime From %s Where T_Truck=''%s''  ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      if not nNeedManu then
        Result := True;
      Exit;
    end;

    nLastTime := FieldByName('T_LastTime').AsDateTime;
    if Now - nLastTime <= 0.02 then
    begin
      Result := True;
      nMsg := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
      nMsg := Format(nMsg, [nTruck,nTruck]);
      Exit;
    end;
    //����ʶ��ɹ�
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nMsg := '����[ %s ]����ʶ��ʧ��,����Ա��ֹ';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nMsg := '����[ %s ]����ʶ��ʧ��,����Ա����';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nMsg := '����[ %s ]����ʶ��ʧ��';
      nMsg := Format(nMsg, [nTruck]);
      nUpdate := False;
      if not nNeedManu then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  nEvent := '����[ %s ]����ʶ��ʧ��';
  nEvent := Format(nEvent, [nTruck]);

  nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill.FID+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  FDM.ExecuteSQL(nStr);
end;

//Desc: �Ƿ���Ҫ��֤��ǩ
function VerifyFQSumValue: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyFQValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
  //xxxxx
end;

//Date: 2017-09-27
//Parm: �ſ���;���ƺ�
//Desc: ΪnTruck���������۴ſ�
function SaveBillLSCard(const nCard,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillLSCard, nCard, nTruck, @nOut);
end;

//Date: 2017-09-27
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2017-09-27
//Parm: �ſ���
//Desc: ע��nCard
function LogoutBillCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2017-09-27
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2017-09-27
//Parm: ��λ;�������б�;��վͨ��
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nLogin, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2017-09-27
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('��������:%s %s', [nDelimiter, FId]));
    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('����ſ�:%s %s', [nDelimiter, FCard]));
    Add(Format('��������:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('�ͻ�����:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Date: 2017-09-27
//Parm: ���ƺţ����ӱ�ǩ���Ƿ����ã��ɵ��ӱ�ǩ
//Desc: ����ǩ�Ƿ�ɹ����µĵ��ӱ�ǩ
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nTruck;
  nP.FParamB := nOldCard;
  nP.FParamC := nIsUse;
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);

  nRFIDCard := nP.FParamB;
  nIsUse    := nP.FParamC;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Desc: ������ЧƤ��
function GetTruckEmptyValue(const nTruck, nType: string): Double;
var nStr: string;
begin
  Result := 0;

  if nType <> sFlag_San then
    Exit;
    
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyTruckP]);

  with FDM.QueryTemp(nStr) do
  if Recordcount > 0 then
  begin
    nStr := Fields[0].AsString;
    if nStr <> sFlag_Yes then Exit;
    //��У��Ƥ��
  end;

  nStr := 'Select top 1 L_PValue From %s Where L_Truck=''%s'' order by R_ID desc';
  nStr := Format(nStr, [sTable_Bill, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
  //xxxxx
end;

//Date: 2017-09-27
//Parm: ���ƺ�
//Desc: �鿴�����ϴι���ʱ����
function GetTruckLastTime(const nTruck: string): Integer;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := -1;
  //Ĭ������

  nStr := 'Select Top 1 %s as T_Now,P_PDate,P_MDate ' +
          'From %s Where P_Truck=''%s'' Order By P_ID Desc';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_PoundLog, nTruck]);
  //ѡ�����һ�ι���

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nNow   := FieldByName('T_Now').AsDateTime;
    nPDate := FieldByName('P_PDate').AsDateTime;
    nMDate := FieldByName('P_MDate').AsDateTime;

    if nPDate > nMDate then
         Result := Trunc((nNow - nPDate) * 24 * 60 * 60)
    else Result := Trunc((nNow - nMDate) * 24 * 60 * 60);
  end;
end;

function GetTruckLastTimeEx(const nTruck: string; var nLast: Integer): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select %s as T_Now,T_LastTime From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nLast := Trunc((FieldByName('T_Now').AsDateTime -
                    FieldByName('T_LastTime').AsDateTime) * 24 * 60 * 60);
    Result := True;                
  end;
end;

//Desc: �ϸ����ɢװ����
function IsStrictSanValue: Boolean;
var nSQL: string;
begin
  Result := False;

  nSQL := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_StrictSanVal]);

  with FDM.QueryTemp(nSQL) do
   if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
  //xxxxx
end;

//Date: 2017-09-27
//Parm: ������;��&��
//Desc: ��բ̧��
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_OpenDoorByReader, nReader, nType,
            @nOut, False);
  //xxxxx
end;  

//------------------------------------------------------------------------------
//Desc: ÿ���������
function GetHYMaxValue: Double;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Desc: ��ȡnNoˮ���ŵ��ѿ���
function GetHYValueByStockNo(const nNo: string): Double;
var nStr: string;
begin
  nStr := 'Select R_SerialNo,Sum(H_Value) From %s ' +
          ' Left Join %s on H_SerialNo= R_SerialNo ' +
          'Where R_SerialNo=''%s'' Group By R_SerialNo';
  nStr := Format(nStr, [sTable_StockRecord, sTable_StockHuaYan, nNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[1].AsFloat
  else Result := -1;
end;

//------------------------------------------------------------------------------
//��ȡ�ͻ�ע����Ϣ
function getCustomerInfo(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_getCustomerInfo, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//�ͻ���΢���˺Ű�
function get_Bindfunc(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessWechat(cBC_WX_get_Bindfunc, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//������Ϣ
function send_event_msg(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessWechat(cBC_WX_send_event_msg, nData, '', '', @nOut,false) then
       Result := nOut.FData
  else Result := '';
end;

//�����̳��û�
function edit_shopclients(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_edit_shopclients, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//�����Ʒ
function edit_shopgoods(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessWechat(cBC_WX_edit_shopgoods, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//��ȡ������Ϣ
function get_shoporders(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessWechat(cBC_WX_get_shoporders, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//���¶���״̬
function complete_shoporders(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessWechat(cBC_WX_complete_shoporders, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//------------------------------------------------------------------------------
//Desc: ��ӡ�����
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�����?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //�������
  
  nStr := 'Select * From %s b Left Join %s on C_ID=L_CusID ' +
          ' Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, sTable_Customer, nBill]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �ļ�¼����Ч!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;
  if Length(FDM.QueryTemp(nStr).FieldByName('L_OutFact').AsString) > 0 then
    nStr := gPath + sReportDir + 'LadingBill.fr3'
  else
    nStr := gPath + sReportDir + 'LadingPlanBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterBill = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterBill;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ӡ������ŵ��
function PrintCNSReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�����?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //�������

  nStr := 'Select * From %s b Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, nBill]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �ļ�¼����Ч!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterBill = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterBill;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2017-09-27
//Parm: ��������;�Ƿ�ѯ��
//Desc: ��ӡnPound������¼
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���ؼ�¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2017-09-27
//Parm: ��������;�Ƿ�ѯ��
//Desc: ��ӡnPound������¼
function PrintPoundOtherReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select top 1 * From %s pl '+
  'Left Join %s oo On oo.R_ID=pl.P_OrderBak'+
  ' Where pl.P_ID=''%s'' order by pl.R_ID desc';
  nStr := Format(nStr, [sTable_PoundLog, sTable_CardOther, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���ؼ�¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'PoundOther.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: ��ȡnStockƷ�ֵı����ļ�
function GetReportFileByStock(const nStock: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  if Pos('dj', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else Result := '';
end;

//Desc: ��ȡnStockƷ�ֵı����ļ�(�����ݿ��ȡģ������)
function GetReportFileByStockFromDB(const nStock, nBrand: string): string;
var nStr, nWhere: string;
begin
  Result := '';
  if nBrand <> '' then
  begin
    nWhere := ' and D_ParamB = ''%s'' ';
    nWhere := Format(nWhere, [nBrand]);
  end
  else
    nWhere := '';

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo = ''%s'' %s order by D_ID desc';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ReportFileMap, nStock, nWhere]);

  with FDM.QuerySQL(nStr) do
  begin
    if RecordCount > 0 then
    begin
      Result := gPath + 'Report\' + Fields[0].AsString;
    end;
  end;
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSR: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '�Ƿ�Ҫ��ӡ���鵥?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �Ļ��鵥��¼����Ч!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  //nStr := GetReportFileByStock(nStr);

  nStr := GetReportFileByStockFromDB(nStr, '');

  WriteLog('�����ļ�·��:' + nStr);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterHYDan = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReportEx(const nBill: string; var nHint: string): Boolean;
var nStr: string;
begin
  nHint := '';
  Result := False;

  nStr := 'Select sr.*,sb.* From %s sr ' +
          ' Left Join %s sb on sr.R_SerialNo=sb.L_HYDan ' +
          ' Where sb.L_ID = ''%s''';
  nStr := Format(nStr, [sTable_StockRecord, sTable_Bill, nBill]);

  WriteLog('���鵥��ѯ:'+nStr);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nHint := '�����[ %s ]û�ж�Ӧ�Ļ��鵥';
      nHint := Format(nHint, [nBill]);
      Exit;
    end;

    nStr := FieldByName('L_StockName').AsString;
    //nStr := GetReportFileByStock(nStr);

    nStr := GetReportFileByStockFromDB(nStr, '');

    WriteLog('�����ļ�·��:' + nStr);

    if not FDR.LoadReportFile(nStr) then
    begin
      nHint := '�޷���ȷ���ر����ļ�: ' + nStr;
      Exit;
    end;

    if gSysParam.FPrinterHYDan = '' then
         FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
    else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;

    FDR.Dataset1.DataSet := FDM.SQLTemp;
    FDR.ShowReport;
    Result := FDR.PrintSuccess;
  end;
end;

//Desc: ��ӡ��ʶΪnID�ĺϸ�֤
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '�Ƿ�Ҫ��ӡ�ϸ�֤?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nStr := 'Select * From $HY hy ' +
          '  Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          '  Left Join $SP sp On sp.P_Stock=b.L_StockNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$SP', sTable_StockParam), MI('$SR', sTable_StockRecord),
          MI('$Bill', sTable_Bill), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �Ļ��鵥��¼����Ч!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterHYDan = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;
  
  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2017-10-17
//Parm: �����б�;ѯ��
//Desc: ��ӡnBatcode�ķ����ص�
function PrintBillHD(const nBatcode: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '�Ƿ�Ҫ��ӡ�����ص�?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nStr := 'Select * From %s Where R_Batcode in (%s)';
  nStr := Format(nStr, [sTable_BatRecord, nBatcode]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �����μ�¼����Ч!!';
    nStr := Format(nStr, [nBatcode]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'BatRecord.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select L_ID,L_CusName,L_Type,L_Value,L_OutFact,L_HYDan From %s ' +
          'Where L_HYDan In (%s)';
  nStr := Format(nStr, [sTable_Bill, nBatcode]);

  FDM.QuerySQL(nStr);
  //������ϸ

  if gSysParam.FPrinterHYDan = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);
  
  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2017-11-22
//Parm: ��������,�̳����뵥
//Desc: ����������Ϣ
procedure SaveWebOrderMsg(const nLID, nWebOrderID: string);
var nStr: string;
    nBool: Boolean;
begin
  if nWebOrderID = '' then
    Exit;
  //�ֹ���

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
//    nStr := 'Delete From %s  Where WOM_LID=''%s''';
//    nStr := Format(nStr, [sTable_WebOrderMatch, nLID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,' +
            'WOM_MsgType,WOM_BillType) Values(''%s'',''%s'',%d,' +
            '%d,''%s'')';
//    nStr := Format(nStr, [sTable_WebOrderMatch, nWebOrderID, nLID, c_WeChatStatusDeleted,
//            cSendWeChatMsgType_DelBill, sFlag_Sale]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
  except
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Date: 2014-09-17
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nOrder;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Provide;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: �ſ���
//Desc: ע��nCard
function LogoutOrderCard(const nCard: string;const nNeiDao:string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_LogOffOrderCard, nCard, nNeiDao, @nOut);
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ɾ��nBillID����
function DeleteOrder(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrder, nOrder, '', @nOut);
end;

//Date: 2014-09-15
//Parm: ������;�³���
//Desc: �޸�nOrder�ĳ���ΪnTruck.
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_ModifyBillTruck, nOrder, nTruck, @nOut);
end;

//Date: 2012-4-1
//Parm: �ɹ�����;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnOrder�ɹ�����
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
    nPath:string;
begin
  Result := False;
  nPath := '';
  
  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�ɹ���?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount>0 then
  begin
    nPath := gPath + 'Report\PurchaseOrder.fr3';
  end
  else begin
    nStr := 'Select * From %s oo where R_id=''%s''';
    nStr := Format(nStr, [sTable_CardOther, nOrder]);

    nDS := FDM.QueryTemp(nStr);
    if not Assigned(nDS) then Exit;
    if nDS.RecordCount>0 then
    begin
      nPath := gPath + 'Report\TempOrder.fr3';
    end;    
  end;

  if nPath='' then
  begin
    nStr := '�ɹ�������ʱ��[ %s ] ����Ч!!';
    ShowMsg(nStr, sHint);
    Exit;
  end;

  if not FDR.LoadReportFile(nPath) then
  begin
    nStr := '�޷���ȷ���ر����ļ�['+nPath+']';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//�����Ƿ����δ��ɲɹ���
function IFHasOrder(const nTruck: string): Boolean;
var nStr: string;
begin
  Result := False;
  //�ſ�Ϊ�ղ�����
  nStr :=' select D_ID from %s where D_Status <> ''%s'' and D_Truck =''%s'' and isnull(D_Card,'''') <> '''' ';
  nStr := Format(nStr, [sTable_OrderDtl, sFlag_TruckOut, nTruck]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ����ɹ���,���زɹ������б�
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-17
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

function getPrePInfo(const nTruck:string;var nPrePValue: Double; var nPrePMan: string;
  var nPrePTime: TDateTime):Boolean;
var
  nStr:string;
begin
  Result := False;
  nPrePValue := 0;
  nPrePMan := '';
  nPrePTime := 0;

  nStr := 'select T_PrePValue,T_PrePMan,T_PrePTime from %s where t_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck,nTruck,sflag_yes]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      nPrePTime := FieldByName('T_PrePTime').asDateTime;
      nPrePValue := FieldByName('T_PrePValue').asFloat;;
      nPrePMan := FieldByName('T_PrePMan').asString;
      Result := True;
    end;
  end;
end;

function GetLastPInfo(const nID:string;var nPValue: Double; var nPMan: string;
  var nPTime: TDateTime):Boolean;
var
  nStr:string;
begin
  Result := False;
  nPValue := 0;
  nPMan := '';
  nPTime := 0;

  nStr := 'select top 1 P_PValue,P_PMan,P_PDate from %s' +
          ' where P_OrderBak=''%s'' order by R_ID desc';
  nStr := format(nStr,[sTable_PoundLog,nID]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      nPTime := FieldByName('P_PDate').asDateTime;
      nPValue := FieldByName('P_PValue').asFloat;;
      nPMan := FieldByName('P_PMan').asString;
      Result := True;
    end;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�;��վͨ��
//Desc: ����nPost��λ�ϵĽ���������
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem;const nLogin: Integer): Boolean;
var nStr, nHint: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
    nIsPreTruck:Boolean;
    nPrePValue: Double;
    nPrePMan: string;
    nPrePTime: TDateTime;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nLogin, nList);
      //capture file

      //�ɹ����ڿ���ɽ�ж������ؼ�¼
      nStr := '';
      if nPost = sFlag_TruckBFM then
      begin
        nIsPreTruck := getPrePInfo(nData[0].FTruck,nPrePValue,nPrePMan,nPrePTime);
        if (nData[0].FCtype=sFlag_CardGuDing) and nIsPreTruck then
        begin
          nStr := GetLastPID(nData[0].FID);
        end;
      end;
      if nStr = '' then
        nStr := nOut.FData;

      {$IFDEF SyncDataByWSDL}
      JudgePurOrder(nStr, nHint);
      {$ENDIF}
      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nStr, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2014-09-17
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('�ɹ�����:%s %s', [nDelimiter, FZhiKa]));
//    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStockName]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('�ͻ��ſ�:%s %s', [nDelimiter, FCard]));
    Add(Format('��������:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('�� Ӧ ��:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Date: 2018-02-06
//Parm: ��Ӧ��ID
//Desc: ͬ��ERP�ɹ���Ӧ��
function SyncPProvider(const nProID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhProvider, nProID, '', @nOut);
end;

//Date: 2018-02-06
//Parm: ����ID
//Desc: ͬ��ERP�ɹ�����
function SyncPMaterail(const nMID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhProvideMateriel, nMID, '', @nOut);
end;

//Date: 2018-02-06
//Parm: ��Ӧ��,����,�ƻ�����
//Desc: ��ȡERP�ɹ������ƻ�
function GetHhOrderPlan(const nStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetHhOrderPlan, nStr, '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-03-23
//Parm: �ͻ�ID,��˾ID,����ID,��װ����ID
//Desc: ��ȡERPί�г���
function GetHhSaleWTTruck(const nStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_SyncHhSaleWTTruck, nStr, '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-02-08
//Parm: ����,�ƻ�����
//Desc: ��ȡERP�ɹ��ڵ������ƻ�
function GetHhNeiDaoOrderPlan(const nStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetHhNeiDaoOrderPlan, nStr, '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-02-06
//Parm: �ɹ���ϸID
//Desc: ͬ��ERP�ɹ�����
function SyncHhOrderData(const nDID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhOrderPoundData, nDID, '', @nOut);
end;

//Date: 2018-02-08
//Parm: ����ID
//Desc: ͬ��ERP�ڵ��ɹ�����
function SyncHhNdOrderData(const nDID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhNdOrderPoundData, nDID, '', @nOut);
end;

//Date: 2018-03-06
//Parm: ����ID
//Desc: ͬ��ERP��Ʒ�����ɹ�����
function SyncHhOtherOrderData(const nDID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhOtOrderPoundData, nDID, '', @nOut);
end;

//Desc: ���ڿ��Ƿ�ʧЧ
function GetCardGInvalid: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_CardGInvalid]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
  //xxxxx
end;

//Param: StockName
//Desc: ��ȡ��ͷ����(�ϴ�ͬƷ��)
function GetShipName(const nStockName :string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select top 1 O_Ship From %s Where O_StockName=''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_Order, nStockName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
  //xxxxx
end;

//Param: �ɹ�����
//Desc: ��ȡ���°�����
function GetLastPID(const nOID :string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select top 1 P_ID From %s Where P_OrderBak =''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_PoundLog, nOID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
  //xxxxx
end;

//Date: 2018-03-07
//Parm: ����������
//Desc: ��ȡERP���ۼƻ�
function GetHhSalePlan(const nFactoryName: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetHhSalePlan, nFactoryName, '', @nOut);
end;

//Date: 2018-03-07
//Desc: ��ȡERP��������
function SyncSMaterail(const nMID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhSaleMateriel, nMID, '', @nOut);
end;

//Date: 2018-03-08
//Parm: �ͻ�ID
//Desc: ͬ��ERP���ۿͻ�
function SyncSCustomer(const nCusID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhCustomer, nCusID, '', @nOut);
end;

procedure SaveTruckPrePValue(const nTruck, nValue: string);
var nStr: string;
begin
  nStr := 'update %s set T_PrePValue=%s,T_PrePMan=''%s'',T_PrePTime=%s '
          + ' where t_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck,nValue,gSysParam.FUserName
                      ,sField_SQLServer_Now,nTruck,sflag_yes]);
  FDM.ExecuteSQL(nStr);
end;

function GetPrePValueSet: Double;
var nStr: string;
begin
  Result := 30;//init

  nStr := 'Select D_Value From $Table ' +
          'Where D_Name=''$Name'' and D_Memo=''$Memo''';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_SysParam),
                            MI('$Memo', sFlag_SetPValue)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      nStr := Fields[0].AsString;
    if IsNumber(nStr,True) then
      Result := StrToFloatDef(nStr,30);
  end;
end;

//Date: 2014-09-18
//Parm: ���ƺ�;��վͨ��
//Desc: ����nTruck��Ԥ��Ƥ����Ƭ
function SaveTruckPrePicture(const nTruck: string;const nTunnel: PPTTunnelItem;
                            const nLogin: Integer): Boolean;
var nStr,nRID: string;
    nIdx: Integer;
    nList: TStrings;
begin
  Result := False;
  nRID := '';
  nStr := 'Select R_ID From %s Where T_Truck =''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    nRID := Fields[0].AsString;
  end;

  nStr := 'Delete from %s where P_ID=''%s'' ';
  nStr := format(nStr,[sTable_Picture, nRID]);
  FDM.ExecuteSQL(nStr);

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nLogin, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nRID, nTruck, '', nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

function InitCapture(const nTunnel: PPTTunnelItem; var nLogin: Integer): Boolean;
const
  cRetry = 2;
  //���Դ���
var nStr: string;
    nIdx,nInt: Integer;
    nErr: Integer;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  Result := False;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  try
    nLogin := -1;
    gCameraNetSDKMgr.NET_DVR_SetDevType(nTunnel.FCamera.FType);
    //xxxxx

    gCameraNetSDKMgr.NET_DVR_Init;
    //xxxxx

    for nIdx:=1 to cRetry do
    begin
      nLogin := gCameraNetSDKMgr.NET_DVR_Login(nTunnel.FCamera.FHost,
                   nTunnel.FCamera.FPort,
                   nTunnel.FCamera.FUser,
                   nTunnel.FCamera.FPwd, nInfo);
      //to login

      nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '��¼�����[ %s.%d ]ʧ��,������: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        if nLogin > -1 then
         gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
        gCameraNetSDKMgr.NET_DVR_Cleanup();
        Exit;
      end;
    end;
    Result := True;
  except

  end;
end;

function FreeCapture(nLogin: Integer): Boolean;
begin
  Result := False;
  try
    if nLogin > -1 then
     gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
    gCameraNetSDKMgr.NET_DVR_Cleanup();

    Result := True;
  except

  end;
end;

procedure UpdateTruckStatus(const nID: string);
var nStr: string;
begin
  nStr := 'update %s set D_Status=''%s'',D_NextStatus=''%s'''
          + ' where D_ID=''%s''';
  nStr := format(nStr,[sTable_OrderDtl,sFlag_TruckBFM,
                       sFlag_TruckBFM,nID]);
  FDM.ExecuteSQL(nStr);
end;

//Date: 2018-03-13
//Parm: ���ID
//Desc: ͬ��ERP������ϸ
function SyncHhSaleDetail(const nDID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncHhSaleDetail, nDID, '', @nOut);
end;

//Desc: ��ȡë����ֵ
function GetMaxMValue(const nType, nID, nCusID, nCusName, nTruck: string): Double;
var nStr, nTime: string;
begin
  Result := 0;

  if nType <> sFlag_San then
    Exit;

  nStr := 'Select * From %s Where X_CusName=''%s''';
  nStr := Format(nStr, [sTable_TruckXz, sFlag_TruckXzTotal]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
      Exit;

    if FieldByName('X_Valid').AsString <> sFlag_Yes then
      Exit;
    Result := FieldByName('X_XzValue').AsFloat;
  end;
  WriteLog('���������ܿ�������:���ض���:' + FloatToStr(Result));

  nStr := 'Select L_MValueMax From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    if Fields[0].AsFloat > 0 then
    begin
      Result := Fields[0].AsFloat;
      WriteLog('��������ʹ���˹��������ض���:' + FloatToStr(Result));
      Exit;
    end;
  end;
  //xxxxx

  if nCusName = '' then
    Exit;

  nStr := 'Select * From %s Where X_CusName=''%s'' and X_Valid = ''%s'' ' +
          'And X_TruckType = (Select T_TruckType from %s where T_Truck = ''%s'')';
  nStr := Format(nStr, [sTable_TruckXz, nCusName, sFlag_Yes, sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nTime := FormatDateTime('HH:MM:SS', Now);

      First;

      while not Eof do
      begin
        if (StrToTime(nTime) > StrToTime(FieldByName('X_BeginTime').AsString) ) and
           (StrToTime(nTime) <= StrToTime(FieldByName('X_EndTime').AsString) ) then
        begin
          Result := FieldByName('X_XzValue').AsInteger;
          WriteLog('��������ʹ�ÿͻ�ר������:���ض���:' + FloatToStr(Result));
          Exit;
        end;
        Next;
      end;
    end;
  end;

  if nTruck = '' then
    Exit;

  nStr := 'Select T_MaxXz From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    if Fields[0].AsFloat > 0 then
    begin
      Result := Fields[0].AsFloat;
      WriteLog('��������ʹ�ó����������ض���:' + FloatToStr(Result));
    end;
  end;
  //xxxxx
end;

//Desc: ��ȡ��������
function GetSaleOrderRestValue(const nID: string): Double;
var nStr: string;
begin
  Result := 0;

  nStr := 'Select (O_PlanRemain - O_Freeze) As O_RestValue From %s Where O_Order=''%s''';
  nStr := Format(nStr, [sTable_SalesOrder, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := FieldByName('O_RestValue').AsFloat;
  //xxxxx
end;

//Desc: ��ʱ����ҵ�����Ƿ�����ϰ�
function IsTruckCanPound(const nItem: TLadingBillItem): Boolean;
var nStr,nPreFix: string;
begin
  Result := False;

  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,nItem.FZhiKa) <= 0 then
    Exit;

  nStr := 'Select *, (O_PlanAmount - O_Freeze - O_HasDone - O_StopAmount) '+
          ' As O_RestValue From %s Where O_Order=''%s''';
  nStr := Format(nStr, [sTable_SalesOrder, nItem.FZhiKa]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    WriteLog('����'+nItem.FZhiKa+'����:'+FieldByName('O_RestValue').AsString);
    if FieldByName('O_RestValue').AsFloat > nItem.FValue then
      Result := True;
  end;

  if Result then
  begin
    nStr := 'Update %s Set O_Freeze=O_Freeze+(%.2f) Where O_Order=''%s''';
    nStr := Format(nStr, [sTable_SalesOrder, nItem.FValue,
            nItem.FZhiKa]);
    FDM.ExecuteSQL(nStr);
  end;

end;

//Date: 2018-03-22
//Parm: ���ϱ��;�ͻ�����;������
//Desc: ��ȡ���κ�
function GetBatchCode(const nStockNo,nCusName: string; nValue: Double): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['StockNo'] := nStockNo;
    nList.Values['CusName'] := nCusName;

    nStr := FloatToStr(nValue);

    if CallBusinessCommand(cBC_GetStockBatcode, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;
end;

//Date: 2018-03-22
//Parm: ��������;��������
//Desc: ��ȡ���ϱ��
function GetStockNo(const nStockName,nStockType: string): string;
var nStr: string;
begin
  Result := '';

  nStr := 'Select D_ParamB From %s Where D_Name = ''%s'' ' +
          'And D_Memo=''%s'' and D_Value like ''%%%s%%''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem,
                        nStockType,
                        Trim(nStockName)]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      Result := Fields[0].AsString;
  end;
end;

//Date: 2017-11-22
//Parm: ��������,�̳����뵥
//Desc: ����ɾ��������Ϣ
procedure SaveWebOrderDelMsg(const nLID, nBillType: string);
var nStr, nWebOrderID: string;
    nBool: Boolean;
begin
  nStr := 'Select WOM_WebOrderID From %s Where WOM_LID=''%s'' ';
  nStr := Format(nStr, [sTable_WebOrderMatch, nLID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
    begin
      WriteLog('��ѯ�̳����뵥ʧ��:' + nStr);
      Exit;
    end;
    //�ֹ���
    nWebOrderID := Fields[0].AsString;
  end;

  nStr := 'Insert Into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,' +
          'WOM_MsgType,WOM_BillType) Values(''%s'',''%s'',%d,' +
          '%d,''%s'')';
  nStr := Format(nStr, [sTable_WebOrderMatch, nWebOrderID, nLID, c_WeChatStatusDeleted,
          cSendWeChatMsgType_DelBill, nBillType]);
  FDM.ExecuteSQL(nStr);
end;

function GetMinNetValue: Double;
var nStr: string;
begin
  Result := 2000;//init

  nStr := 'Select D_Value From $Table ' +
          'Where D_Name=''$Name'' and D_Memo=''$Memo''';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_SysParam),
                            MI('$Memo', sFlag_MinNetValue)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      nStr := Fields[0].AsString;
    if IsNumber(nStr,True) then
      Result := StrToFloatDef(nStr,2000);
  end;
end;

//Desc: ��ѯ����ҵ�������
function GetSaleOrderDoneValue(const nOID, nCusName, nStockName: string): string;
var nStr,nPreFix: string;
begin
  Result := '';

  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,nOID) <= 0 then
    Exit;

  nStr := 'Select sum(pl.P_MValue-pl.P_PValue) From %s pl ' +
          'Left Join %s bl On ((bl.L_ID=pl.P_Bill) or (bl.L_ID=pl.P_OrderBak) ) ' +
          'Left Join %s so On so.O_Order=bl.L_ZhiKa ' +
          'Where P_MName = ''%s'' and P_CusName = ''%s'' And so.O_Order like ''%%%s%%'' ';
  nStr := Format(nStr, [sTable_PoundLog, sTable_Bill,
                        sTable_SalesOrder, nStockName, nCusName, nPreFix]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

//Desc: ��ѯ����ҵ�񶳽���
function GetSaleOrderFreezeValue(const nOID: string): string;
var nStr,nPreFix: string;
begin
  Result := '';

  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,nOID) <= 0 then
    Exit;

  nStr := 'Select Sum(L_Value) From %s Where L_Status <> ''%s''' +
          ' And L_Zhika=''%s''';
  nStr := Format(nStr, [sTable_Bill, sFlag_TruckOut, nOID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

//Desc: ��鳵���Ƿ����δע���ſ��������(�������ҵ��)
function CheckTruckCard(const nTruck: string; var nLID: string): Boolean;
var nStr: string;
begin
  Result := True;

  nStr := 'Select L_Card, L_ID From %s Where L_Truck=''%s''';
  nStr := Format(nStr, [sTable_Bill, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin

    First;

    while not Eof do
    begin
      if Length(Fields[0].AsString) > 0 then
      begin
        nLID := Fields[1].AsString;
        Result := False;
        Exit;
      end;
      Next;
    end;
  end;
end;

//Desc: ����Ƿ�Ϊ��ʱ����
function IsOtherOrder(const nItem: TLadingBillItem): Boolean;
var nStr,nPreFix: string;
begin
  Result := False;

  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,nItem.FZhiKa) <= 0 then
    Exit;

  Result := True;
end;

//Date: 2018-04-03
//Parm: �������
//Desc: ��֤�����Ƿ������ʱ
function IsTruckTimeOut(const nLID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_TruckTimeOut, nLID, '', @nOut);
  //xxxxx
end;

function GetEventDept: string;
var nStr: string;
begin
  Result := sFlag_DepDaTing;//init

  nStr := 'Select D_Value From $Table ' +
          'Where D_Name=''$Name'' and D_Memo=''$Memo''';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_SysParam),
                            MI('$Memo', sFlag_EventDept)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      Result := Fields[0].AsString;
  end;
end;


//Date: 2018-02-06
//Parm: ��Ӧ��ID
//Desc: ͬ��ERP�ɹ���Ӧ��
function SyncPProviderWSDL(const nProID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhProvider, nProID, '', '', @nOut, False);
end;

//Date: 2018-02-06
//Parm: ��Ӧ��,����,�ƻ�����
//Desc: ��ȡERP�ɹ������ƻ�
function GetHhOrderPlanWSDL(const nStr: string): string;
var nOut: TWorkerHHJYData;
begin
  if CallBusinessHHJY(cBC_GetHhOrderPlan, nStr, '', '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-03-23
//Parm: �ͻ�ID,��˾ID,����ID,��װ����ID
//Desc: ��ȡERPί�г���
function GetHhSaleWTTruckWSDL(const nStr: string): string;
var nOut: TWorkerHHJYData;
begin
  if CallBusinessHHJY(cBC_SyncHhSaleWTTruck, nStr, '', '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-02-08
//Parm: ����,�ƻ�����
//Desc: ��ȡERP�ɹ��ڵ������ƻ�
function GetHhNeiDaoOrderPlanWSDL(const nStr: string): string;
var nOut: TWorkerHHJYData;
begin
  if CallBusinessHHJY(cBC_GetHhNeiDaoOrderPlan, nStr, '', '', @nOut) then
    Result := nOut.FData
  else Result := '';
end;

//Date: 2018-02-06
//Parm: �ɹ���ϸID
//Desc: ͬ��ERP�ɹ�����
function SyncHhOrderDataWSDL(const nDID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhOrderPoundData, nDID, '', '', @nOut);
end;

//Date: 2018-02-08
//Parm: ����ID
//Desc: ͬ��ERP�ڵ��ɹ�����
function SyncHhNdOrderDataWSDL(const nDID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhNdOrderPoundData, nDID, '', '', @nOut);
end;

//Date: 2018-03-06
//Parm: ����ID
//Desc: ͬ��ERP��Ʒ�����ɹ�����
function SyncHhOtherOrderDataWSDL(const nDID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhOtOrderPoundData, nDID, '', '', @nOut);
end;

//Date: 2018-03-07
//Parm: ����������
//Desc: ��ȡERP���ۼƻ�
function GetHhSalePlanWSDL(const nWhere, nFactoryName: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_GetHhSalePlan, nWhere, nFactoryName, '', @nOut, False);
end;

//Date: 2018-03-07
//Desc: ��ȡERP��������
function SyncSMaterailWSDL(const nMID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhSaleMateriel, nMID, '', '', @nOut, False);
end;

//Date: 2018-03-08
//Parm: �ͻ�ID
//Desc: ͬ��ERP���ۿͻ�
function SyncSCustomerWSDL(const nCusID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhCustomer, nCusID, '', '', @nOut, False);
end;

//Date: 2018-03-13
//Parm: ���ID
//Desc: ͬ��ERP������ϸ
function SyncHhSaleDetailWSDL(const nDID: string): Boolean;
var nOut: TWorkerHHJYData;
begin
  Result := CallBusinessHHJY(cBC_SyncHhSaleDetail, nDID, '', '', @nOut);
end;

//Date: 2018-03-13
//Parm: ���ID
//Desc: ��ȡ���κ�
function GetHhSaleWareNumberWSDL(const nOrder, nValue: string;
                                 var nHint: string): string;
var nOut: TWorkerHHJYData;
    nStr: string;
    nList: TStrings;
    nEID, nEvent, nStockName, nStockType: string;
    nRestVal, nWarnVal: Double;
begin
  Result := '';
  nHint := '';
  nList := TStringList.Create;
  nRestVal := 0;
  try
    nStr := 'Select O_FactoryID, O_StockID, O_PackingID, O_StockName,' +
            ' O_STockType,O_CusID From %s Where O_Order =''%s'' ';
    nStr := Format(nStr, [sTable_SalesOrder, nOrder]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nList.Values['FactoryID'] := Fields[0].AsString;
      nList.Values['StockID']   := Fields[1].AsString;
      nList.Values['PackingID'] := Fields[2].AsString;
      nList.Values['Amount']    := nValue;
      nList.Values['CusID']     := Fields[5].AsString;
      nStockName := Fields[3].AsString;
      nStockType := Fields[4].AsString;

      nStr := PackerEncodeStr(nList.Text);
      if CallBusinessHHJY(cBC_GetHhSaleWareNumber, nStr, '', '', @nOut, False) then
      begin
        nStr := PackerDecodeStr(nOut.FData);
        nList.Clear;
        nList.Text := nStr;
        try
          if IsNumber(nList.Values['FAmount'], True) and
             IsNumber(nList.Values['FDeliveryAmount'], True) then
          begin
            nRestVal := StrToFloat(nList.Values['FAmount']) -
               StrToFloat(nList.Values['FDeliveryAmount']) -
               StrToFloat(nValue);
            if nRestVal >= 0 then
            begin
              Result := nList.Values['FWareNumber'];
            end;
          end;
        except
        end;
      end
      else
      begin
        nHint := PackerDecodeStr(nOut.FData);
      end;
    end
    else
    begin
      nHint := '����[ %s ]������';
      nHint := Format(nHint,[nOrder]);
      Exit;
    end;

    if Result = '' then
    begin
      nEID := nList.Values['FactoryID'] +
              nList.Values['StockID'] +
              nList.Values['PackingID'];

      nStr := 'Delete From %s Where E_ID=''%s''';
      nStr := Format(nStr, [sTable_ManualEvent, nEID]);

      FDM.ExecuteSQL(nStr);

      nEvent := 'ˮ��Ʒ��[ %s ]�����α�����þ�,�뻯���Ҿ��첹¼';
      nEvent := Format(nEvent,[nStockname + nStockType]);

      nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', ''),
          SF('E_From', sFlag_DepDaTing),
          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_OK),
          SF('E_Departmen', sFlag_DepHauYanShi),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, '', True);
      FDM.ExecuteSQL(nStr);
    end
    else
    begin
      nWarnVal := 200;
      nStr := 'Select D_Value From %s Where D_Name=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_HYDanWarnVal]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        nWarnVal := Fields[0].AsFloat;
      end;
      //xxxxx
      if nRestVal <= nWarnVal then
      begin
        nEID := nList.Values['FactoryID'] +
                nList.Values['StockID'] +
                nList.Values['PackingID'] + 'BZ';;

        nStr := 'Delete From %s Where E_ID=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nEID]);

        FDM.ExecuteSQL(nStr);

        nEvent := 'ˮ��Ʒ��[ %s ]�����α�ſ�����[ %.2f ],�뻯������ǰ׼��';
        nEvent := Format(nEvent,[nStockname + nStockType, nRestVal]);

        nStr := MakeSQLByStr([
            SF('E_ID', nEID),
            SF('E_Key', ''),
            SF('E_From', sFlag_DepDaTing),
            SF('E_Event', nEvent),
            SF('E_Solution', sFlag_Solution_OK),
            SF('E_Departmen', sFlag_DepHauYanShi),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, '', True);
        FDM.ExecuteSQL(nStr);

        nStr := MakeSQLByStr([
            SF('E_ID', nEID),
            SF('E_Key', ''),
            SF('E_From', sFlag_DepDaTing),
            SF('E_Event', nEvent),
            SF('E_Solution', sFlag_Solution_OK),
            SF('E_Departmen', sFlag_DepDaTing),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, '', True);
        FDM.ExecuteSQL(nStr);
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2018-03-13
//Parm: ���ID
//Desc: ��ȡ���κ�
function PoundVerifyHhSalePlanWSDL(const nLID: string; nValue: Double;
                                   nPriceDate:string;
                                 var nHint: string): Boolean;
var nOut: TWorkerHHJYData;
    nStr: string;
    nList: TStrings;
begin
  Result := False;
  nHint := '';
  nList := TStringList.Create;

  try
    if not CallBusinessHHJY(cBC_IsHhSaleDetailExits
           ,PackerEncodeStr(nLID),'','',@nOut) then
    begin
      nHint := '��ȡ�����[ %s ]���IDʧ��,�볢�������ϴ������.';
      nHint := Format(nHint, [nLID]);
      Exit;
    end;
    nList.Text := PackerDecodeStr(nOut.FData);

    if not IsNumber(nList.Values['FGoodsPrice'], True) then
    begin
      nHint := '��ȡ�����[ %s ]����[ %s ]�쳣,��˶�.';
      nHint := Format(nHint, [nLID, nList.Values['FGoodsPrice']]);
      Exit;
    end;

    nList.Values['FPriceDate'] := nPriceDate;
    nList.Values['FPoundValue'] := FloatToStr(nValue);
    nList.Values['FMoney'] := Format('%.2f', [StrToFloat(nList.Values['FGoodsPrice'])
                                              * nValue]);

    nStr := PackerEncodeStr(nList.Text);
    if  not CallBusinessHHJY(cBC_PoundVerifyHhSalePlan, nStr, '', '', @nOut, False) then
    begin
      nHint := '�����[ %s ]�س�����У��ʧ��.ԭ��Ϊ:[ �˻��ʽ��� ]';
      nHint := Format(nHint, [nLID]);
      Exit;
    end;
    Result := True;
  finally
    nList.Free;
  end;
end;

//Date: 2019-06-13
//Parm: ���ID
//Desc: ����У��ͻ��ʽ�
function KDVerifyHhSalePlanWSDL(const nPrice, nValue: Double;
                                   nPriceDate:string;
                                 var nHint: string): Boolean;
var nOut: TWorkerHHJYData;
    nStr: string;
    nList: TStrings;
begin
  WriteLog('�����ʽ�У��:�۸�' + FloatToStr(nPrice) + '�����:' +
           FloatToStr(nValue));
  Result := False;
  nHint := '';
  nList := TStringList.Create;

  try
    nList.Values['FPriceDate'] := nPriceDate;
    nList.Values['FPoundValue'] := FloatToStr(nValue);
    nList.Values['FMoney'] := Format('%.2f', [nPrice * nValue]);

    nStr := PackerEncodeStr(nList.Text);
    if  not CallBusinessHHJY(cBC_PoundVerifyHhSalePlan, nStr, '', '', @nOut, False) then
    begin
      WriteLog('����ʧ��:' + nOut.FData);
      nHint := '����ʧ��.[ �����쳣���˻��ʽ��� ]';
      Exit;
    end;
    Result := True;
  finally
    nList.Free;
  end;
end;


function GetCusID(const nCusName :string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select top 1 C_ID From %s Where C_Name =''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_Customer, nCusName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
  //xxxxx
end;

function IsMulMaoStock(const nStockNo :string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Value=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundMultiM, nStockNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := True;
  //xxxxx
end;

function IsAsternStock(const nStockName :string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Value=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundAsternM, nStockName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := True;
  //xxxxx
end;

function UpdateKCValue(const nLID :string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Update %s Set L_Value = 0 Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nLID]);
  FDM.ExecuteSQL(nStr);
  //xxxxx
end;

function GetOrderID(const nOID :string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select O_BID From %s Where O_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, nOID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
  //xxxxx
end;

//Date: 2018-03-22
//Parm: ԭ���϶���ID
//Desc: У�鶩���Ƿ���Ч
function VerifyPurOrder(const nID: string; var nHint: string): Boolean;
var nStr, nData,nDate, nYear: string;
    nIdx, nOrderCount: Integer;
    nListA, nListB: TStrings;
    nDateNow: TDateTime;
begin
  Result := False;
  nHint := '';
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    try
      nDateNow := FDM.ServerNow;
      nDate := FormatDateTime('YYYY-MM-',nDateNow) + '26';
      if nDateNow > StrToDate(nDate) then
       nDate := FormatDateTime('YYYY-MM',IncMonth(nDateNow))
      else
       nDate := FormatDateTime('YYYY-MM',nDateNow);
    except
       nDate := FormatDateTime('YYYY-MM',nDateNow);
    end;

    {$IFDEF SyncDataByWSDL}
    nStr := 'FEntryPlanNumber = ''%s'' ';
    nStr := Format(nStr, [nID]);

    nStr := PackerEncodeStr(nStr);

    nData := GetHhOrderPlanWSDL(nStr);

    if nData = '' then
    begin
      nHint := '�ɹ�����' + nID + '������ʧЧ';
      Exit;
    end;

    nListB.Text := PackerDecodeStr(nData);

    nYear     := nListB.Values['FYearPeriod'];

    nData := '��ǰ��������[ %s ]�ɹ�����[ %s ]�����ƻ�����[ %s ]';
    nData := Format(nData,[nDate, nID, nYear]);
    WriteLog(nData);

    if nYear <> nDate then
    begin
      nData := '��ǰ��������[ %s ]��ɹ�����[ %s ]�����ƻ�����[ %s ]��һ��,�ɹ�����������ʧЧ';
      nData := Format(nData,[nDate, nID, nYear]);
      nHint := nData;
      Exit;
    end;
    Result := True;
    {$ENDIF}
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

function GetMaxLadeValue(const nTruck: string): Double;
var nStr: string;
begin
  Result := 0;

  nStr := 'Select T_MaxLadeValue From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
      if IsNumber(nStr,True) then
        Result := StrToFloat(nStr);
    end;
  end;
end;

function VerifySnapTruck(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
var nStr, nDept: string;
    nNeedManu, nUpdate, nST, nSuccess: Boolean;
    nSnapTruck, nTruck, nEvent, nPicName: string;
    nLen: Integer;
begin
  Result := False;
  nPos := '';
  nNeedManu := False;
  nSnapTruck := '';
  nDept := '';
  nMsg := '';
  nLen := 0;
  nSuccess := False;
  nTruck := nBill.Ftruck;

  nPos := ReadPoundReaderInfo(nReader,nDept);

  if nPos = '' then
  begin
    Result := True;
    nStr := '������[ %s ]�󶨸�λΪ��,�޷�����ץ��ʶ��.';
    nStr := Format(nStr, [nReader]);
    WriteLog(nStr);
    Exit;
  end;

  nST := True;

  nStr := 'Select T_SnapTruck From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nST := FieldByName('T_SnapTruck').AsString = sFlag_Yes;
    end;
  end;

  if not nST then
  begin
    Result := True;
    nMsg := '����[ %s ]������г���ʶ��';
    nMsg := Format(nMsg, [nTruck]);
    Exit;
  end;

  nStr := 'Select D_Value,D_Index From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;
      nLen := FieldByName('D_Index').AsInteger;
      if nNeedManu then
      begin
        nStr := '������[ %s ]�󶨸�λ[ %s ]��Ԥ����:�˹���Ԥ������.';
        nStr := Format(nStr, [nReader, nPos]);
        WriteLog(nStr);
      end
      else
      begin
        nStr := '������[ %s ]�󶨸�λ[ %s ]��Ԥ����:�˹���Ԥ�ѹر�.';
        nStr := Format(nStr, [nReader, nPos]);
        WriteLog(nStr);
        Result := True;
      end;
    end
    else
    begin
      Result := True;
      nStr := '������[ %s ]�󶨸�λ[ %s ]δ���ø�Ԥ����,�޷�����ץ��ʶ��.';
      nStr := Format(nStr, [nReader, nPos]);
      WriteLog(nStr);
      Exit;
    end;
  end;

  if not nNeedManu then//����Ԥ У��ʶ���¼����������ͳ��ʧ����
  begin
    nStr := 'Select * From %s order by R_ID desc ';
    nStr := Format(nStr, [sTable_SnapTruck]);
    //xxxxx

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        Exit;
      end;

      nPicName := '';

      First;

      while not Eof do
      begin
        nSnapTruck := FieldByName('S_Truck').AsString;
        if nPicName = '' then//Ĭ��ȡ����һ��ץ��
          nPicName := FieldByName('S_PicName').AsString;
        if Pos(nTruck,nSnapTruck) > 0 then
        begin
          nSuccess := True;
          nPicName := FieldByName('S_PicName').AsString;
          //ȡ��ƥ��ɹ���ͼƬ·��
          nMsg := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
          nMsg := Format(nMsg, [nTruck,nSnapTruck]);
        end
        else
        if nLen > 0 then//ģ��ƥ��
        begin
          if RightStr(nTruck,nLen) = RightStr(nSnapTruck,nLen) then
          begin
            nSuccess := True;
            nPicName := FieldByName('S_PicName').AsString;
            //ȡ��ƥ��ɹ���ͼƬ·��
            nMsg := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
            nMsg := Format(nMsg, [nTruck,nTruck]);
          end;
          //����ʶ��ɹ�
        end;

        if nSuccess then
          Exit;
        Next;
      end;
    end;

    nStr := 'Select * From %s Where E_ID=''%s''';
    nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nUpdate := True;
      end
      else
      begin
        nUpdate := False;
      end;
    end;

    nEvent := '����[ %s ]����ʶ��ʧ��,���ƶ���������ҹ��رճ���';
    nEvent := Format(nEvent, [nTruck]);

    nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
    nStr := MakeSQLByStr([
            SF('E_ID', nBill.FID+sFlag_ManualE),
            SF('E_Key', nPicName),
            SF('E_From', nPos),
            SF('E_Result', 'O'),

            SF('E_Event', nEvent),
            SF('E_Solution', sFlag_Solution_OK),
            SF('E_Departmen', nDept),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, nStr, (not nUpdate));
    //xxxxx
    FDM.ExecuteSQL(nStr);
    Exit;
  end;

  nStr := 'Select * From %s order by R_ID desc ';
  nStr := Format(nStr, [sTable_SnapTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      if not nNeedManu then
        Result := True;
      Exit;
    end;

    nPicName := '';

    First;

    while not Eof do
    begin
      nSnapTruck := FieldByName('S_Truck').AsString;
      if nPicName = '' then//Ĭ��ȡ����һ��ץ��
        nPicName := FieldByName('S_PicName').AsString;
      if Pos(nTruck,nSnapTruck) > 0 then
      begin
        Result := True;
        nPicName := FieldByName('S_PicName').AsString;
        //ȡ��ƥ��ɹ���ͼƬ·��
        nMsg := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
        nMsg := Format(nMsg, [nTruck,nSnapTruck]);
        Exit;
      end
      else
      if nLen > 0 then//ģ��ƥ��
      begin
        if RightStr(nTruck,nLen) = RightStr(nSnapTruck,nLen) then
        begin
          Result := True;
          nPicName := FieldByName('S_PicName').AsString;
          //ȡ��ƥ��ɹ���ͼƬ·��
          nMsg := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
          nMsg := Format(nMsg, [nTruck,nTruck]);
          Exit;
        end;
        //����ʶ��ɹ�
      end;
      Next;
    end;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nMsg := '����[ %s ]����ʶ��ʧ��,����Ա��ֹ';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nMsg := '����[ %s ]����ʶ��ʧ��,����Ա����';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nUpdate := False;
      if not nNeedManu then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  nEvent := '����[ %s ]����ʶ��ʧ��,���ƶ���������ҹ��رճ���';
  nEvent := Format(nEvent, [nTruck]);

  nMsg := nEvent;

  nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill.FID+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  FDM.ExecuteSQL(nStr);
end;

function SaveSnapStatus(const nBill: TLadingBillItem; nStatus: string): Boolean;
var nStr: string;
begin
  Result := True;

  if nStatus = sFlag_No then
  begin
    nStr := 'update %s set L_SnapStatus=''%s'' where L_ID=''%s''';
    nStr := format(nStr,[sTable_Bill, nStatus, nBill.FID]);
    FDM.ExecuteSQL(nStr);
  end
  else
  begin
    nStr := 'Select * From %s Where E_ID=''%s''';
    nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        if Trim(FieldByName('E_Result').AsString) <> '' then //����Ԥ������ʹ�ɹ�Ҳ���ٸ���
        begin
          Exit;
        end;
        nStr := 'update %s set L_SnapStatus=''%s'' where L_ID=''%s''';
        nStr := format(nStr,[sTable_Bill, nStatus, nBill.FID]);
        FDM.ExecuteSQL(nStr);

        nStr := 'Delete From %s Where E_ID=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);
        FDM.ExecuteSQL(nStr);
      end
      else
      begin
        nStr := 'update %s set L_SnapStatus=''%s'' where L_ID=''%s''';
        nStr := format(nStr,[sTable_Bill, nStatus, nBill.FID]);
        FDM.ExecuteSQL(nStr);
      end;
    end;
  end;
end;

//Date: 2018-08-03
//Parm: ������ID
//Desc: ��ȡnReader��λ������
function ReadPoundReaderInfo(const nReader: string; var nDept: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nDept:= '';
  //����

  if CallBusinessHardware(cBC_GetPoundReaderInfo, nReader, '', @nOut)  then
  begin
    Result := Trim(nOut.FData);
    nDept:= Trim(nOut.FExtParam);
  end;
end;

procedure RemoteSnapDisPlay(const nPost, nText, nSucc: string);
var nOut: TWorkerBusinessCommand;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Values['text'] := nText;
    nList.Values['succ'] := nSucc;

    CallBusinessHardware(cBC_RemoteSnapDisPlay, nPost, PackerEncodeStr(nList.Text), @nOut);
  finally
    nList.Free;
  end;
end;

//Date: 2019-07-12
//Parm: ����ID
//Desc: У��ԭ���϶���
function JudgePurOrder(const nID: string; var nHint: string): Boolean;
var nStr, nData,nDate, nYear, nStockNo, nProNo, nKD: string;
    nIdx, nOrderCount: Integer;
    nListA, nListB: TStrings;
    nDateNow: TDateTime;
    nUpdate: Boolean;
begin
  Result := False;
  nHint := '';

  WriteLog('��ʼУ������Ƿ���������:' + nID);
  nStr := 'Select P_MID,P_CusID,P_Year,P_KD From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
    begin
      WriteLog('����' + nID + '������');
      Exit;
    end;
    nStockNo := Fields[0].AsString;
    nProNo := Fields[1].AsString;
    nYear := Fields[2].AsString;
    nKD := Fields[3].AsString;
  end;

  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    try
      nDateNow := FDM.ServerNow;
      nDate := FormatDateTime('YYYY-MM-',nDateNow) + '26';
      if nDateNow > StrToDate(nDate) then
       nDate := FormatDateTime('YYYY-MM',IncMonth(nDateNow))
      else
       nDate := FormatDateTime('YYYY-MM',nDateNow);
    except
       nDate := FormatDateTime('YYYY-MM',nDateNow);
    end;

    if nYear = nDate then
    begin
      Result := True;
      nHint := '��ǰ��������[ %s ]�����[ %s ]�����ƻ�����[ %s ]һ��,�����������';
      nHint := Format(nHint,[nDate, nID, nYear]);
      WriteLog(nHint);
      Exit;
    end;

    {$IFDEF SyncDataByWSDL}
    nStr := 'FYearPeriod =''%s'' and FStatus =''254'' and FCancelStatus =''0'' and FMaterialProviderID = ''%s'' and FMaterielNumber =''%s'' ';
    nStr := Format(nStr, [nDate, nProNo, nStockNo]);

    nStr := PackerEncodeStr(nStr);

    nData := GetHhOrderPlanWSDL(nStr);

    if nData = '' then
    begin
      nHint := '����[ %s ]����[ %s ]��Ӧ��[ %s ]��������[ %s ]��ȡ�ɹ�����ʧ��';
      nHint := Format(nHint,[nID, nStockNo, nProNo, nDate]);
      WriteLog(nHint);
      Exit;
    end;

    nListA.Text := PackerDecodeStr(nData);
    nOrderCount := nListA.Count;

    nUpDate := False;
    for nIdx := 0 to nOrderCount - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA.Strings[nIdx]);

      if (nKD <> '') and (nListB.Values['KD'] = nKD) then
      begin
        nStr := 'Update %s Set P_BID=''%s'',P_Model=''%s'','+
                ' P_Year=''%s'',P_KD=''%s'' '+
                ' Where P_ID=''%s''';
        nStr := Format(nStr, [sTable_PoundLog,nListB.Values['Order'],
                                            nListB.Values['Model'],
                                            nDate,
                                            nListB.Values['KD'],
                                            nID]);
        WriteLog('����' + nID + '���' + nKD + '��������SQL:' + nStr);
        FDM.ExecuteSQL(nStr);
        nUpdate := True;
        Break;
      end;
    end;

    if not nUpdate then//�����޿�����ֻ�ɿ�㲻����
    begin
      for nIdx := 0 to nOrderCount - 1 do
      begin
        nListB.Text := PackerDecodeStr(nListA.Strings[nIdx]);

        nStr := 'Update %s Set P_BID=''%s'',P_Model=''%s'','+
                ' P_Year=''%s'',P_KD=''%s'' '+
                ' Where P_ID=''%s''';
        nStr := Format(nStr, [sTable_PoundLog,nListB.Values['Order'],
                                            nListB.Values['Model'],
                                            nDate,
                                            nListB.Values['KD'],
                                            nID]);
        WriteLog('����' + nID + '��������SQL:' + nStr);
        FDM.ExecuteSQL(nStr);
      end;
    end;
    Result := True;
    WriteLog('����У������Ƿ���������:' + nID);
    {$ENDIF}
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

procedure UpdateMultMStatus(const nID: string);
var nStr: string;
begin
  nStr := 'Update %s Set L_Status=''%s'',L_NextStatus=''%s'' ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, sFlag_TruckFH, sFlag_TruckBFM, nID]);

  FDM.ExecuteSQL(nStr);
end;

end.
