{*******************************************************************************
  ����: dmzn@163.com 2017-09-21
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  Classes, SysUtils, UBusinessPacker, ULibFun, USysDB;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*query field define*}
  cQF_Bill                    = $0001;
  
  {*business command*}
  cBC_GetSerialNO             = $0001;   //��ȡ���б��
  cBC_ServerNow               = $0002;   //��������ǰʱ��
  cBC_IsSystemExpired         = $0003;   //ϵͳ�Ƿ��ѹ���
  cBC_GetCardUsed             = $0004;   //��ȡ��Ƭ����
  cBC_UserLogin               = $0005;   //�û���¼
  cBC_UserLogOut              = $0006;   //�û�ע��

  cBC_SaveTruckInfo           = $0013;   //���泵����Ϣ
  cBC_UpdateTruckInfo         = $0017;   //���泵����Ϣ
  cBC_GetTruckPoundData       = $0015;   //��ȡ������������
  cBC_SaveTruckPoundData      = $0016;   //���泵����������

  cBC_SaveBills               = $0020;   //���潻�����б�
  cBC_DeleteBill              = $0021;   //ɾ��������
  cBC_PostBill                = $0022;   //���˽�����
  cBC_ReverseBill             = $0023;   //����������
  cBC_SaleAdjust              = $0024;   //���۵���
  cBC_SaveBillCard            = $0025;   //�󶨽������ſ�
  cBC_LogoffCard              = $0026;   //ע���ſ�
  cBC_SaveBillLSCard          = $0027;   //�󶨳������۴ſ�
  cBC_ModifyBillTruck         = $0028;   //�޸ĳ��ƺ�

  cBC_GetPostBills            = $0030;   //��ȡ��λ������
  cBC_SavePostBills           = $0031;   //�����λ������
  cBC_ChangeDispatchMode      = $0032;   //�л�����ģʽ

  cBC_SaveOrder               = $0040;
  cBC_DeleteOrder             = $0041;
  cBC_SaveOrderCard           = $0042;
  cBC_LogOffOrderCard         = $0043;
  cBC_GetPostOrders           = $0044;   //��ȡ��λ�ɹ���
  cBC_SavePostOrders          = $0045;   //�����λ�ɹ���
  cBC_SaveOrderBase           = $0046;   //����ɹ����뵥
  cBC_DeleteOrderBase         = $0047;   //ɾ���ɹ����뵥
  cBC_GetGYOrderValue         = $0048;   //��ȡ���ջ���

  cBC_RemoteSnapDisPlay       = $0051;   //ץ��С����ʾ
  cBC_GetPoundReaderInfo      = $0052;   //��ȡ��վ��������λ������
  cBC_GetPoundCard            = $0054;   //��ȡ��վ����
  cBC_GetQueueData            = $0055;   //��ȡ��������
  cBC_PrintCode               = $0056;   //����:��������
  cBC_PrintFixCode            = $0057;   //����:�̶�����
  cBC_PrinterEnable           = $0058;   //����:��ͣ
  cBC_GetStockBatcode         = $0059;   //��ȡ���α��

  cBC_JSStart                 = $0060;   //����:����
  cBC_JSStop                  = $0061;   //����:ֹͣ
  cBC_JSPause                 = $0062;   //����:��ͣ
  cBC_JSGetStatus             = $0063;   //����:״̬
  cBC_SaveCountData           = $0064;   //����:����
  cBC_RemoteExecSQL           = $0065;

  cBC_IsTunnelOK              = $0075;   //����:ͨ���ж�
  cBC_TunnelOC                = $0076;   //����:ͨ������
  cBC_PlayVoice               = $0077;   //����:��������
  cBC_OpenDoorByReader        = $0078;   //��բ:̧��
  cBC_ShowTxt                 = $0079;   //����:����С��

  cBC_VerifySnapTruck         = $0081;   //���Ʊȶ�
  cBC_TruckTimeOut            = $0082;   //ɢװ����������ʱ
  cBC_VerifyTruckStatus       = $0083;   //У�鳵��״̬

  cBC_SyncHhSaleMateriel      = $0091;   //ͬ����������
  cBC_SyncHhProvideMateriel   = $0092;   //ͬ���ɹ�����
  cBC_SyncHhCustomer          = $0093;   //ͬ�����ۿͻ�
  cBC_SyncHhProvider          = $0094;   //ͬ���ɹ���Ӧ��
  cBC_GetHhOrderPlan          = $0095;   //��ȡ�ɹ������ƻ�
  cBC_SyncHhOrderPoundData    = $0096;   //�ϴ��ɹ�����
  cBC_GetHhNeiDaoOrderPlan    = $0097;   //��ȡ�ɹ��ڵ������ƻ�
  cBC_SyncHhNdOrderPoundData  = $0098;   //�ϴ��ɹ��ڵ�����
  cBC_SyncHhOtOrderPoundData  = $0099;   //�ϴ��ɹ���ʱ����
  cBC_GetHhSalePlan           = $0100;   //��ȡ���ۼƻ�
  cBC_SyncHhSaleDetail        = $0101;   //�ϴ����۷�����ϸ
  cBC_SyncHhSaleWTTruck       = $0102;   //��ȡ����ί�г���
  cBC_PoundVerifyHhSalePlan   = $0103;   //���ۼƻ�����У��
  cBC_BillVerifyHhSalePlan    = $0104;   //���ۼƻ�����У��
  cBC_IsHhSaleDetailExits     = $0105;   //��ѯ������ϸ
  cBC_GetHhSaleDetailID       = $0106;   //��ȡ����������ϸID
  cBC_GetHhSaleWareNumber     = $0107;   //��ȡ���κ�

  cBC_IsHhOrderDetailExits    = $0108;   //��ѯ��ͨԭ���ϲɹ�����ϸ
  cBC_GetHhOrderDetailID      = $0109;   //��ȡ������ͨԭ���ϲɹ�����ϸID

  cBC_IsHhNdOrderDetailExits  = $0110;   //��ѯ�ڵ�ԭ���ϲɹ�����ϸ
  cBC_GetHhNdOrderDetailID    = $0111;   //��ȡ�����ڵ�ԭ���ϲɹ�����ϸID

  cBC_IsHhOtherOrderDetailExits= $0112;  //��ѯ��ʱ���زɹ�����ϸ
  cBC_GetHhOtherOrderDetailID = $0113;   //��ȡ������ʱ���زɹ�����ϸID

  cBC_SyncHhSaleWareNumber    = $0114;   //ͬ�����κ�
  cBC_GetHhSaleRealPrice      = $0115;   //��ȡ���¼۸�

  cBC_NewHhWTDetail           = $0116;   //�����ɳ���

  cBC_SaveHhHyData            = $0117;   //��ȡ���鵥���ݲ����汾��
  cBC_GetHhHyHxDetail         = $0118;   //��ȡ���鵥��ѧ����

  cBC_GetHhHyWlDetail         = $0119;   //��ȡ���鵥�������
  cBC_GetHhHyWlBZCD           = $0120;   //��ȡ���鵥���������׼���
  cBC_GetHhHyWlNjTime         = $0121;   //��ȡ���鵥�����������ʱ��
  cBC_GetHhHyWlXD             = $0122;   //��ȡ���鵥�������ϸ��
  cBC_GetHhHyWlBiBiao         = $0123;   //��ȡ���鵥��������ȱ����
  cBC_GetHhHyWlQD             = $0124;   //��ȡ���鵥�������ǿ��

  cBC_GetHhHyHhcDetail        = $0125;   //��ȡ���鵥��ϲ�
  cBC_GetHhHyHhcRecord        = $0126;   //��ȡ���鵥��ϲ���ϸ

  cBC_WX_VerifPrintCode       = $0501;   //΢�ţ���֤������Ϣ
  cBC_WX_WaitingForloading    = $0502;   //΢�ţ�������װ��ѯ
  cBC_WX_BillSurplusTonnage   = $0503;   //΢�ţ����϶������µ�������ѯ
  cBC_WX_GetOrderInfo         = $0504;   //΢�ţ���ȡ������Ϣ
  cBC_WX_GetOrderList         = $0505;   //΢�ţ���ȡ�����б�
  cBC_WX_GetPurchaseContract  = $0506;   //΢�ţ���ȡ�ɹ���ͬ�б�

  cBC_WX_getCustomerInfo      = $0507;   //΢�ţ���ȡ�ͻ�ע����Ϣ
  cBC_WX_get_Bindfunc         = $0508;   //΢�ţ��ͻ���΢���˺Ű�
  cBC_WX_send_event_msg       = $0509;   //΢�ţ�������Ϣ
  cBC_WX_edit_shopclients     = $0510;   //΢�ţ������̳��û�
  cBC_WX_edit_shopgoods       = $0511;   //΢�ţ������Ʒ
  cBC_WX_get_shoporders       = $0512;   //΢�ţ���ȡ������Ϣ
  cBC_WX_complete_shoporders  = $0513;   //΢�ţ��޸Ķ���״̬
  cBC_WX_get_shoporderbyNO    = $0514;   //΢�ţ����ݶ����Ż�ȡ������Ϣ
  cBC_WX_get_shopPurchasebyNO = $0515;   //΢�ţ����ݶ����Ż�ȡ������Ϣ
  cBC_WX_ModifyWebOrderStatus = $0516;   //΢�ţ��޸����϶���״̬
  cBC_WX_CreatLadingOrder     = $0517;   //΢�ţ�����������
  cBC_WX_GetCusMoney          = $0518;   //΢�ţ���ȡ�ͻ��ʽ�
  cBC_WX_GetInOutFactoryTotal = $0519;   //΢�ţ���ȡ������ͳ��
  cBC_WX_GetAuditTruck        = $0520;   //΢�ţ���ȡ��˳���
  cBC_WX_UpLoadAuditTruck     = $0521;   //΢�ţ���˳�������ϴ�
  cBC_WX_DownLoadPic          = $0522;   //΢�ţ�����ͼƬ
  cBC_WX_get_shoporderbyTruck = $0523;   //΢�ţ����ݳ��ƺŻ�ȡ������Ϣ

  cBC_WX_get_shopBigorderbyNO = $0524;   //΢�ţ����ݶ����Ż�ȡ�󶩵���Ϣ

  cBC_VeryTruckLicense        = $1006;   //����ʶ��

  cBC_GetLoginToken           =  $0601;   //���ŵ�¼�ӿ�
  cBC_GetDepotInfo            =  $0602;   //��ȡ���Ų��ŵ���
  cBC_GetUserInfo             =  $0603;   //��ȡ������Ա����
  cBC_GetCusProInfo           =  $0604;   //��ȡ���ſ��̵���
  cBC_GetStockType            =  $0605;   //��ȡ���Ŵ������
  cBC_GetStockInfo            =  $0606;   //��ȡ���Ŵ������
  cBC_GetOrderInfo            =  $0607;   //��ȡ���Ųɹ�������Ϣ
  cBC_GetOrderInfoEx          =  $0615;   //��ȡ���Ųɹ�������Ϣ(�����ݿ�)
  cBC_GetOrderPound           =  $0608;   //��ȡ���Ųɹ������ӿ�
  cBC_GetSaleInfo             =  $0609;   //��ȡ�������۶�����Ϣ
  cBC_GetSalePound            =  $0610;   //��ȡ�������۰����ӿ�
  cBC_GetHYInfo               =  $0611;   //��ȡ�����ʼ���Ϣ
  cBC_GetPoundKW              =  $0612;   //��ȡ�񵥿�����Ϣ
  cBC_GetOrderTruckNum        =  $0613;   //��ȡ�ɹ������������볧����
  cBC_GetSaleTruckNum         =  $0614;   //��ȡ���۶����������볧����

type
  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //����
    FData     : string;            //����
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
  end;

  TWorkerSapURL = record
    FSapName: string;              //������
    FSapURL: string;               //ҵ���ַ
    FSapParam: string;             //ҵ�����
    FSapMethod: string;            //ҵ�񷽷�
    FEncodeURL: Boolean;           //���ܵ�ַ
    FEncodeXML: Boolean;           //����XML
  end;

  TTWorkerSapURLs = array of TWorkerSapURL;
  //��ַ�б�

  TPoundStationData = record
    FStation  : string;            //��վ��ʶ
    FValue    : Double;           //Ƥ��
    FDate     : TDateTime;        //��������
    FOperator : string;           //����Ա
  end;

  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //��������
    FNewID      : string;          //���˵���
    FZhiKa      : string;          //ֽ�����
    FCusID      : string;          //�ͻ����
    FCusName    : string;          //�ͻ�����
    FTruck      : string;          //���ƺ���

    FType       : string;          //Ʒ������
    FStockNo    : string;          //Ʒ�ֱ��
    FStockName  : string;          //Ʒ������
    FValue      : Double;          //�����
    FPrice      : Double;          //�������

    FCard       : string;          //�ſ���
    FIsVIP      : string;          //ͨ������
    FStatus     : string;          //��ǰ״̬
    FNextStatus : string;          //��һ״̬

    FPData      : TPoundStationData; //��Ƥ
    FMData      : TPoundStationData; //��ë
    FFactory    : string;          //�������
    FPModel     : string;          //����ģʽ
    FPType      : string;          //ҵ������
    FPoundID    : string;          //���ؼ�¼
    FSelected   : Boolean;         //ѡ��״̬

    FYSValid    : string;          //���ս����Y���ճɹ���N���գ�
    FKZValue    : Double;          //��Ӧ�۳�
    FPrintHY    : Boolean;         //��ӡ���鵥
    FHYDan      : string;          //���鵥��
    FMemo       : string;          //������ע
    FWebOrderID : string;          //�̳����뵥
    FNeiDao     : string;          //�ڵ�
    Fexpiretime : string;
    FCtype      : string;          //�����ͣ�'L'����ʱ��'G'���̶�
    FPoundIdx   : Integer;          //�����ϳ���˳��
    FPoundMax   : Integer;          //�����ϳ����ܴ���
    FPrintBD    : Boolean;         //��ӡ����
    FModel      : string;          //�ͺ�
  end;

  TLadingBillItems = array of TLadingBillItem;
  //�������б�

  PWorkerWebChatData = ^TWorkerWebChatData;
  TWorkerWebChatData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
    FRemoteUL : string;            //����������UL
  end;

  PWorkerHHJYData = ^TWorkerHHJYData;
  TWorkerHHJYData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
    FRemoteUL : string;            //����������UL
  end;

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//������ҵ����󷵻صĽ���������
function CombineBillItmes(const nItems: TLadingBillItems): string;
//�ϲ�����������Ϊҵ������ܴ�����ַ���

var
  gSapURLs: TTWorkerSapURLs;       //ҵ���б�
  gSapURLInited: Integer = 0;      //�Ƿ��ʼ��

resourcestring
  {*common function*}
  sSys_SweetHeart             = 'Sys_SweetHeart';       //����ָ��
  sSys_BasePacker             = 'Sys_BasePacker';       //���������

  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //����ʾ����

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //ҵ��ģ��
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //Ӳ���ػ�
  sPlug_ModuleRemote          = '{B584DCD7-40E5-413C-B9F3-6DD75AEF1C63}';
                                                        //MIT�������

  {*sap mit function name*}
  sSAP_ServiceStatus          = 'SAP_ServiceStatus';    //����״̬
  sSAP_ReadXSSaleOrder        = 'SAP_Read_XSSaleOrder'; //���۶���
  sSAP_CreateSaleBill         = 'SAP_Create_SaleBill';  //����������
  sSAP_ModifySaleBill         = 'SAP_Modify_SaleBill';  //�޸Ľ�����
  sSAP_DeleteSaleBill         = 'SAP_Delete_SaleBill';  //ɾ��������
  sSAP_PickSaleBill           = 'SAP_Pick_SaleBill';    //���佻����
  sSAP_PostSaleBill           = 'SAP_Post_SaleBill';    //���˽�����
  sSAP_ReverseSaleBill        = 'SAP_Reverse_SaleBill'; //����������
  sSAP_ReadSaleBill           = 'SAP_Read_SaleBill';    //��ȡ������

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //����״̬
  sBus_GetQueryField          = 'Bus_GetQueryField';    //��ѯ���ֶ�

  sBus_ReadXSSaleOrder        = 'Bus_Read_XSSaleOrder'; //���۶���
  sBus_CreateSaleBill         = 'Bus_Create_SaleBill';  //����������
  sBus_ModifySaleBill         = 'Bus_Modify_SaleBill';  //�޸Ľ�����
  sBus_DeleteSaleBill         = 'Bus_Delete_SaleBill';  //ɾ��������
  sBus_PickSaleBill           = 'Bus_Pick_SaleBill';    //���佻����
  sBus_PostSaleBill           = 'Bus_Post_SaleBill';    //���˽�����
  sBus_ReverseSaleBill        = 'Bus_Reverse_SaleBill'; //����������
  sBus_ReadSaleBill           = 'Bus_Read_SaleBill';    //��ȡ������

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //���������
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //ҵ��ָ��
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //Ӳ��ָ��
  sBus_BusinessWebchat        = 'Bus_BusinessWebchat';  //Webƽ̨����
  sBus_BusinessPurchase       = 'Bus_BusinessPurchase'; //�ɹ������
  sBus_BusinessHHJY           = 'Bus_BusinessHHJY';     //��Ӿ�Զ�ӿڷ���

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //����״̬
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //��ѯ���ֶ�

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //������ҵ��
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //ҵ��ָ��
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //Ӳ��ָ��
  sCLI_BusinessWebchat        = 'CLI_BusinessWebchat';  //Webƽ̨����
  sCLI_BusinessPurchaseOrder  = 'CLI_BusinessPurchaseOrder'; //�ɹ������
  sCLI_BusinessHHJY           = 'CLI_BusinessHHJY';     //��Ӿ�Զ�ӿڷ���

implementation

//Date: 2017-09-17
//Parm: ����������;�������
//Desc: ����nDataΪ�ṹ���б�����
procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
var nStr: string;
    nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FID         := Values['ID'];
        FNewID      := Values['NewID'];
        FZhiKa      := Values['ZhiKa'];
        FCusID      := Values['CusID'];
        FCusName    := Values['CusName'];
        FTruck      := Values['Truck'];

        FType       := Values['Type'];
        FStockNo    := Values['StockNo'];
        FStockName  := Values['StockName'];

        FCard       := Values['Card'];
        FIsVIP      := Values['IsVIP'];
        FStatus     := Values['Status'];
        FNextStatus := Values['NextStatus'];

        FFactory    := Values['Factory'];
        FPModel     := Values['PModel'];
        FPType      := Values['PType'];
        FPoundID    := Values['PoundID'];
        FSelected   := Values['Selected'] = sFlag_Yes;

        with FPData do
        begin
          FStation  := Values['PStation'];
          FDate     := Str2DateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FPData.FValue := StrToFloat(nStr)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          FDate     := Str2DateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FMData.FValue := StrToFloat(nStr)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FValue := StrToFloat(nStr)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FPrice := StrToFloat(nStr)
        else FPrice := 0;

        nStr := Trim(Values['KZValue']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FKZValue := StrToFloat(nStr)
        else FKZValue := 0;

        FYSValid := Values['YSValid'];
        FPrintHY := Values['PrintHY'] = sFlag_Yes;
        FHYDan   := Values['HYDan'];
        FMemo    := Values['Memo'];
        FWebOrderID := Values['WebOrderID'];
        FNeiDao  := Values['NeiDao'];
        Fexpiretime := Values['expiretime'];
        FCtype := Values['ctype'];
        FPoundIdx := StrToIntDef(Values['PoundIdx'],0);
        FPoundMax := StrToIntDef(Values['PoundMax'],0);
        FPrintBD := Values['PrintBD'] = sFlag_Yes;
        FModel   := Values['Model'];
      end;

      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

//Date: 2017-09-18
//Parm: �������б�
//Desc: ��nItems�ϲ�Ϊҵ������ܴ����
function CombineBillItmes(const nItems: TLadingBillItems): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    nListB.Clear;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      with nListB do
      begin
        Values['ID']         := FID;
        Values['NewID']      := FNewID;
        Values['ZhiKa']      := FZhiKa;
        Values['CusID']      := FCusID;
        Values['CusName']    := FCusName;
        Values['Truck']      := FTruck;

        Values['Type']       := FType;
        Values['StockNo']    := FStockNo;
        Values['StockName']  := FStockName;
        Values['Value']      := FloatToStr(FValue);
        Values['Price']      := FloatToStr(FPrice);

        Values['Card']       := FCard;
        Values['IsVIP']      := FIsVIP;
        Values['Status']     := FStatus;
        Values['NextStatus'] := FNextStatus;

        Values['Factory']    := FFactory;
        Values['PModel']     := FPModel;
        Values['PType']      := FPType;
        Values['PoundID']    := FPoundID;

        with FPData do
        begin
          Values['PStation'] := FStation;
          Values['PValue']   := FloatToStr(FPData.FValue);
          Values['PDate']    := DateTime2Str(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTime2Str(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := sFlag_Yes
        else Values['Selected'] := sFlag_No;

        Values['KZValue']    := FloatToStr(FKZValue);
        Values['YSValid']    := FYSValid;
        Values['Memo']       := FMemo;
        Values['WebOrderID'] := FWebOrderID;
        if FPrintHY then
             Values['PrintHY'] := sFlag_Yes
        else Values['PrintHY'] := sFlag_No;
        Values['HYDan']    := FHYDan;
        Values['NeiDao']   := FNeiDao;
        Values['expiretime'] := Fexpiretime;
        Values['ctype'] := FCtype;
        Values['PoundIdx'] := IntToStr(FPoundIdx);
        Values['PoundMax'] := IntToStr(FPoundMax);
        if FPrintBD then
             Values['PrintBD'] := sFlag_Yes
        else Values['PrintBD'] := sFlag_No;
        Values['Model'] := FModel;
      end;

      nListA.Add(PackerEncodeStr(nListB.Text));
      //add bill
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

end.


