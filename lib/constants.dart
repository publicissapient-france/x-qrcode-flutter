const MODE_CHECK_IN = 'checkIn';
const MODE_SPONSOR = 'sponsor';
const MODE = [MODE_CHECK_IN, MODE_SPONSOR];

const ROLE_ADMIN = 'ROLE_ADMIN';
const ROLE_SPONSOR = 'ROLE_SPONSOR';

const APP_NAMESPACE = 'http://x-qrcode.techx.fr';

const STORAGE_KEY_ACCESS_TOKEN = 'st_access_token';
const STORAGE_KEY_REFRESH_TOKEN = 'st_refresh_token';
const STORAGE_KEY_TOKEN_EXPIRES_IN = 'st_token_expires_in';
const STORAGE_KEY_USER = 'st_user';
const STORAGE_KEY_EVENT = 'st_event';
const STORAGE_KEY_MODE = 'st_mode';

const ENV_KEY_OAUTH_AUTH_URL = 'OAUTH_AUTH_URL';
const ENV_KEY_OAUTH_AUDIENCE = 'OAUTH_AUDIENCE';
const ENV_KEY_OAUTH_CLIENT_ID = 'OAUTH_CLIENT_ID';
const ENV_KEY_OAUTH_REALM = 'OAUTH_REALM';
const ENV_KEY_OAUTH_SCOPE = 'OAUTH_SCOPE';

const ENV_KEY_API_URL = 'API_URL';

const PRIMARY_COLOR = 0xFFFE414D;
const DISABLE_COLOR = 0xFFCCCCCC;
const BACKGROUND_COLOR = 0xFFEDEDED;

const ANALYTICS_PROPERTY_COMPANY = 'company';
const ANALYTICS_PROPERTY_EVENT = 'event';

const ANALYTICS_EVENT_VISITOR_SCAN = 'visitor_scan';
const ANALYTICS_EVENT_VISITOR_CONSENT = 'visitor_consent';
const ANALYTICS_EVENT_VISITOR_COMMENT = 'visitor_comment';
const ANALYTICS_EVENT_ATTENDEE_SCAN = 'attendee_scan';