//    public static String SERVER_URL = "http://ec2-13-124-193-78.ap-northeast-2.compute.amazonaws.com:8080";     // DEV URL


//public static String SERVER_URL = "https://app.logis-link.co.kr";   // PRO URL

const String m_ServerRelease = "https://app.logis-link.co.kr";    // 운영서버
const String m_ServerDebug = "http://192.168.53.51:9080";         // Local LAN
//const String m_ServerDebug = "http://192.168.68.82:9080";         // Local WIFI
const String m_ServerTest = "http://211.252.86.30:806";           // 테스트서버
//const String m_ServerTest = "http://211.252.86.30:8005";
const String SERVER_URL = m_ServerDebug;

const String RECEIPT_PATH = "/files/receipt/";

const String m_Release = "https://abt.logis-link.co.kr";
const String m_Debug = "http://172.30.1.89:8080";
//const String m_Debug = "http://192.168.0.2:8080";
const String m_Setting = m_Release;

const String JUSO_URL = "https://www.juso.go.kr";
// 카카오 주소검색 URL
const String KAKAO_URL = "https://dapi.kakao.com";

// 도로명 API 주소검색

// 내부 지번 주소 검색
const String URL_JIBUN = "/cmm/jibunlist/v1";

// 산재(차주) 금액 조회
const String URL_INSURE = "/cmm/insure/v1";

// 공통코드
const String URL_CODE_LIST = "/cmm/code/list";
// 버전코드
const String URL_VERSION_CODE = "/cmm/version/list";
// 로그 저장
const String URL_EVENT_LOG = "/cust/insert/eventLog";

// 로그인
const String URL_MEMBER_LOGIN = "/cust/login/A";
const String URL_JUSO = "/addrlink/addrLinkApi.do";

const String URL_CHECK_LOGIN_TIME = "/cust/user/login/timeUpdate";

// 카카오 API 주소검색(좌표 포함)
const String URL_KAKAO_ADDRESS = "/v2/local/search/address.json";
// 사용자 정보
const String URL_USER_INFO = "/cust/user/info";
// 사용자 정보 수정
const String URL_USER_UPDATE = "/cust/user/update";
// 사용자 RPA 정보 수정
const String URL_USER_RPA_UPDATE = "/cust/user/rpa/update";
// 기기 정보 업데이트
const String URL_DEVICE_UPDATE = "/cust/device/update";
// 사용자 탬플릿 등록
const String URL_USER_TEMPLATE_REG = "/cust/user/write/template";
// 사용자 탬플릿 조회
const String URL_USER_TEMPLATE_LIST = "/cust/user/templateList";
// 사용자 탬플릿 상세조회
const String URL_USER_TEMPLATE_DETAIL = "/cust/user/templateDetail";
// 사용자 탬플릿 경유지 조회
const String URL_USER_TEMPLATE_STOP_LIST = "/cust/user/templateStopList";
// 사용자 탬플릿 삭제
const String URL_USER_TEMPLATE_DEL = "/cust/user/delete/template";
// 로그인시 카카오톡 알람 확인
const String URL_LOGIN_ALARM = "/notice/talk/smsSendLoginService";

// 오더 세부 사항
const String URL_ORDER_LIST2= "/cust/order/list/A/v2/order";
// 오더 목록
const String URL_ORDER_LIST = "/cust/order/list/A/v2";
// 오더 등록
const String URL_ORDER_REG = "/cust/order/write/v1";
// 오더 수정
const String URL_ORDER_MOD = "/cust/order/update/v1";
// 오더 취소
const String URL_ORDER_CANCEL = "/cust/order/cancel";
// 오더 재 등록
const String URL_ORDER_STATE = "/cust/order/state";

// 경유지 목록
const String URL_STOP_POINT_LIST = "/cust/orderstop/list";
// 배차 등록
const String URL_ORDER_ALLOC_REG = "/cust/order/alloc/v1";
// 배차 상태 변경
const String URL_ORDER_ALLOC_STATE = "/cust/order/alloc/state";
// 인수증 목록
const String URL_RECEIPT_LIST = "/cust/orderfile/list";
// 차량 검색
const String URL_CAR_LIST = "/cust/customer/vehic";
// 주소지명 목록
const String URL_ADDR_LIST = "/cust/customer/addr";
// 주소지명 등록/수정
const String URL_ADDR_REG = "/cust/customer/addr/write";
// 주소지명 삭제
const String URL_ADDR_DEL = "/cust/customer/addr/delete";
// 등록 거래처 목록
const String URL_CUSTOMER_LIST = "/cust/customer/list";
// 거래처 담당자 목록
const String URL_CUST_USER_LIST = "/cust/user/list";
// 운송사 지정 담당자 목록
const String URL_CUST_USER_LIST2 = "/cust/user/list2";
// 구간별 계약 단가
const String URL_FRT_COST = "/cust/customer/frtCost";
// 차량 위치 관제
const String URL_LBS = "/cust/orderlbs/list";
// 공지사항
const String URL_NOTICE = "/cust/notice/board/list";
// 공지사항 상세
const String URL_NOTICE_DETAIL = "/notice/board/detail?boardSeq=";
// 알림
const String URL_NOTIFICATION = "/cust/notice/push/list";
// 정보망 등록
const String URL_SEND_LINK = "/cust/orderLink/write/v1";
// 정보망 목록
const String URL_LINK_LIST = "/cust/orderLink/list/v1";
// 정보망 일괄 취소
const String URL_LINK_CANCEL = "/cust/orderLink/cancel/v1";
// New : 정보망 배차확정
const String UIRL_LINK_RPA_CONFIRM = "/cust/order/confirmLink";
// New : 정보망 수정
const String URL_LINK_RPA_MOD = "/cust/order/modLink";
// New : 정보망 취소(개별)
const String URL_LINK_RPA_CANCEL = "/cust/order/cancelLink";
// New : 정보망 현황 : 24시콜, 화물맨, 원콜 현황 List
const String URL_LINK_RPA_CURRENT= "/cust/order/linkCurrent";
// New : 정보망 현황 : 기본 데이터
const String URL_LINK_RPA_STATUS = "/cust/order/linkStatus";
// New : 정보망 계정 정보
const String URL_LINK_USER_INFO = "/cust/linkInfo";
// New : 정보망 현황 : 정보망 각 상태 및 금액 얼마 있는지 만 추출 - orderId 위주
const String URL_LINK_RPA_STATUS_SUB = "/cust/order/rpa/getOrderStatusSub";
// New : 정보망 현황 : 정보망 각 상태 및 금액 얼마 있는지 만 추출 - allocId 위주
const String URL_LINK_RPA_STATUS_ALLOC ="/cust/order/rpa/getOrderStatusAlloc";


// New : 정보망 현황 : 정보망 사용 유무 Flag
const String URL_RPA_USE_YN = "/cust/rpa/useYn";


// 시/군/구 목록
const String URL_SIDO_AREA = "/cmm/area/list";
// 부서 목록
const String URL_DEPT_LIST = "/cust/dept/list";
// 커스텀 부서 목록
const String URL_CUSTOM_DEPT_LIST = "/cust/custdept/list";
// 오더&배차현황
const String URL_MONITOR_ORDER = "/cust/monitor/arrangeOrder/v1";
// 실적현황(부서별)
const String URL_MONITOR_DEPT_PROFIT = "/cust/monitor/deptProfit/v1";
// 실적현황(거래처별)
const String URL_MONITOR_CUST_PROFIT = "/cust/monitor/custProfit/v1";
// 업무 초기값
const String URL_OPTION = "/cust/user/option";
// 업무 초기값 설정
const String URL_OPTION_UPDATE = "/cust/user/option/update";
// ID 찾기
const String URL_FIND_ID = "/cust/search/id";
// 비밀번호 찾기
const String URL_FIND_PWD = "/cust/search/pw";

// 단가표 데이터 가져오기(일반용)
const String URL_TMS_UNIT_CHARGE = "/cust/order/tms/unitcharge.do";

// 단가표 데이터 가져오기(운송사 지정시 사용)
const String URL_TMS_UNIT_COMP_CHARGE = "/cust/order/tms/unitCompCharge.do";

// 단가표 조회(Count)
const String URL_TMS_UNIT_CNT = "/cust/order/unitCnt.do";


// TMS 사용자 원콜 포인트 결과 값
const String URL_TMS_POINT_RESULT = "/cust/point/selectPointResult";

// TMS 사용자 원콜 포인트 Info
const String URL_TMS_POINT_USER_INFO = "/cust/point/selectUserPointInfo";

// TMS 사용자 원콜 포인트 Info 리스트
const String URL_TMS_POINT_USER_LIST = "/cust/point/selectUserPointList";

// RPA 로그인 정보 Flag 값
const String URL_RPA_LINK_FLAG = "/cust/order/rpa/getLinkFlag";





// Junghwan.hwang Update
// 약관 동의 확인(ID)
const String URL_TERMS_ID = "/terms/AgreeUserIndex";
// 약관 동의 확인(전화번호)
const String URL_TERMS_TEL = "/terms/AgreeTelIndex";
// 약관 동의 업데이트(필수, 선택항목)
const String URL_TERMS_INSERT = "/terms/insertTermsAgree";
// 약관 동의 기록 DB 저장(insert)
const String URL_TERMS_UPDATE = "/terms/updateTermsAgree";

// 회원가입
const String URL_JOIN = "https://abt.logis-link.co.kr/join.do";

// 서비스 이용약관
//const String URL_SERVICE_TERMS = "https://abt.logis-link.co.kr/terms/service.do";
// 개인정보 처리방침
//const String URL_PRIVACY_TERMS = "https://abt.logis-link.co.kr/terms/privacy.do";
// 위치기반 서비스 이용약관
//const String URL_LBS_TERMS = "https://abt.logis-link.co.kr/terms/lbs.do";

// 2022.10.01 버전
// 이용약관
const String URL_AGREE_TERMS = m_Setting +"/terms/agree.do";
// 개인정보수집이용동의
const String URL_PRIVACY_TERMS = m_Setting +"/terms/privacy.do";
// 개인정보처리방침
const String URL_PRIVATE_INFO_TERMS = m_Setting +"/terms/privateInfo.do";
// 데이터보안서약
const String URL_DATA_SECURE_TERMS = m_Setting +"/terms/dataSecure.do";
// 마케팅정보수신동의
const String URL_MARKETING_TERMS = m_Setting +"/terms/marketing.do";


// 도움말
const String URL_MANUAL = SERVER_URL + "/manual/A/list";