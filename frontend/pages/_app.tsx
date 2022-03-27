import { Auth } from '@aws-amplify/auth';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import type { AppProps } from 'next/app';
import '../styles/globals.css';

Auth.configure({
  // // REQUIRED only for Federated Authentication - Amazon Cognito Identity Pool ID
  // identityPoolId: 'XX-XXXX-X:XXXXXXXX-XXXX-1234-abcd-1234567890ab',

  // REQUIRED - Amazon Cognito Region
  region: 'ap-northeast-1',

  // OPTIONAL - Amazon Cognito Federated Identity Pool Region
  // Required only if it's different from Amazon Cognito Region
  identityPoolRegion: 'ap-northeast-1',

  // OPTIONAL - Amazon Cognito User Pool ID
  userPoolId: process.env.NEXT_PUBLIC_USER_POOL_ID,

  // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  userPoolWebClientId: process.env.NEXT_PUBLIC_USER_POOL_WEB_CLIENT_ID,

  // OPTIONAL - Enforce user authentication prior to accessing AWS resources or not
  mandatorySignIn: false,

  // // OPTIONAL - Configuration for cookie storage
  // // Note: if the secure flag is set to true, then the cookie transmission requires a secure protocol
  // cookieStorage: {
  //   // REQUIRED - Cookie domain (only required if cookieStorage is provided)
  //   domain: '.yourdomain.com',
  //   // OPTIONAL - Cookie path
  //   path: '/',
  //   // OPTIONAL - Cookie expiration in days
  //   expires: 365,
  //   // OPTIONAL - See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite
  //   sameSite: 'strict',
  //   // OPTIONAL - Cookie secure flag
  //   // Either true or false, indicating if the cookie transmission requires a secure protocol (https).
  //   secure: true,
  // },

  // OPTIONAL - customized storage object
  // storage: MyStorage,

  // // OPTIONAL - Manually set the authentication flow type. Default is 'USER_SRP_AUTH'
  // authenticationFlowType: 'USER_PASSWORD_AUTH',

  // // OPTIONAL - Manually set key value pairs that can be passed to Cognito Lambda Triggers
  // clientMetadata: { myCustomKey: 'myCustomValue' },

  // // OPTIONAL - Hosted UI configuration
  // oauth: {
  //   domain: 'hogehoge.auth.ap-northeast-1.amazoncognito.com',
  //   scope: [
  //     // 'phone',
  //     'email',
  //     // 'profile',
  //     // 'openid',
  //     // 'aws.cognito.signin.user.admin',
  //   ],
  //   redirectSignIn: 'http://localhost:3000/callback',
  //   redirectSignOut: 'http://localhost:3000/callback',
  //   responseType: 'code', // or 'token', note that REFRESH token will only be generated when the responseType is code
  // },
});

function MyApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}

export default withAuthenticator(MyApp, {
  hideSignUp: true,
  loginMechanisms: ['email'],
});
