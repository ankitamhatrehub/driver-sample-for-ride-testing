/// Reusable UI strings used across multiple screens.
///
/// Keeps copy centralized for easy i18n and consistency.
class AppStrings {
  AppStrings._();

  // ── App Identity ──────────────────────────────────────────────
  static const String appName = 'Torkk Driver';
  static const String appTitle = 'TORKK';

  // ── Common Actions ────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String skip = 'Skip';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';

  // ── Home / Dashboard ──────────────────────────────────────────
  static const String goOnline = 'Go Online';
  static const String goOffline = 'Go Offline';
  static const String navHome = 'Home';
  static const String navOrders = 'Orders';
  static const String ordersSearchHint = 'Search your rides, parcels';
  static const String ordersCurrent = 'Current';
  static const String ordersCompleted = 'Completed';
  static const String ordersCancelled = 'Cancelled';
  static const String ordersScheduled = 'Scheduled';
  static const String ordersOngoing = 'Ongoing';
  static const String ordersOnline = 'Online';
  static const String ordersEmpty = 'No orders in this tab';
  static const String ordersRide = 'Ride';
  static const String ordersParcel = 'Parcel';
  static const String ordersCoinsHint = 'Complete more orders to get more benefits';
  static const String ordersYouEarnedCoins = 'You earned';
  static const String ordersCoins = 'coins';
  static const String rideDetails = 'Ride Details';
  static const String parcelDetails = 'Parcel Details';
  static const String parcelType = 'Parcel Type';
  static const String rateReceiver = 'Rate Receiver';
  static const String rateReceiverHint = 'Help us maintain a safe and reliable service';
  static const String fairDetails = 'Fair Details';
  static const String fair = 'Fair';
  static const String additionalWaitingCharge = 'Additional Waiting Charger';
  static const String discountCoins = 'Discount/Toins';
  static const String taxes = 'Taxes';
  static const String otherCharges = 'Other Charges';
  static const String totalFair = 'Total Fair';
  static const String paymentStatus = 'Payment Status';
  static const String paidCash = 'Paid Cash';
  static const String passengers = 'passengers';
  static const String driversId = 'Driver\'s ID';
  static const String name = 'Name';
  static const String personalInformation = 'Personal Information';
  static const String vehicleInformation = 'Vehicle Information';
  static const String documentKycStatus = 'Document / KYC Status';
  static const String documentKyc = 'Document/KYC';
  static const String bankInformation = 'Bank Information';
  static const String subscriptionRecharge = 'Subscription/recharge';
  static const String torkkCoins = 'Torkk Coins';
  static const String notifications = 'Notifications';
  static const String notification = 'Notification';
  static const String settings = 'Settings';
  static const String termsConditions = 'Terms & Conditions';
  static const String faq = 'FAQ';
  static const String faqs = 'FAQs';
  static const String helpSupport = 'Help & Support';
  static const String aboutTorkk = 'About Torkk';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout from your account?';
  static const String mobileNumber = 'Mobile Number';
  static const String carModel = 'Car Model';
  static const String changeRequest = 'Change Request';
  static const String edit = 'Edit';
  static const String editReplace = 'Edit / Replace';
  static const String verified = 'Verified';
  static const String pending = 'Pending';
  static const String notStarted = 'Not Started';
  static const String faqSubtitle = 'Find answers about verification, documents, rides, payments and your Torkk account';
  static const String searchQuestions = 'Search Questions';
  static const String answerHelpful = 'Was this answer helpful ?';
  static const String myTickets = 'My Tickets';
  static const String typeMessage = 'Type your message...';
  static const String readMore = 'Read More';
  static const String overview = 'Overview';
  static const String navParcel = 'Parcel';
  static const String navWallet = 'Wallet';
  static const String searchingRides = 'Searching for rides...';
  static const String noRidesAvailable = 'No rides available';
  static const String todayEarnings = 'Today\'s Earnings';
  static const String goodMorning = 'Good morning,';
  static const String goodAfternoon = 'Good afternoon,';
  static const String goodEvening = 'Good evening,';
  static const String youAreOffline = 'You\'re Offline';
  static const String youAreOnline = 'You\'re Online';
  static const String goOnlineHint = 'Go online to start receiving ride requests.';
  static const String readyForRequests = 'Ready to receive ride requests.';
  static const String todayCompletedJobs = 'Today\'s Completed Jobs';
  static const String planYourTime = 'Plan your time, earn more';
  static const String planYourTimeSubtitle = 'Schedule your preferred driving hours.';
  static const String currentLocation = 'Current Location';
  static const String updateLocation = 'Update';
  static const String goOnlineBody = 'You will receive new ride requests while you\'re online';
  static const String goOfflineBody = 'You won\'t receive new ride requests while you\'re offline';
  static const String gettingRideDetails = 'Getting ride details...';
  static const String pleaseWait = 'Please wait';
  static const String parcelDelivery = 'Parcel Delivery';
  static const String unlockParcelTitle = 'Collect 100 coins to unlock Parcel Delivery';
  static const String unlockParcelSubtitle =
      'Collect 100 coins and become eligible to receive parcel delivery requests.';
  static const String completeEarningTasks = 'Complete earning tasks';
  static const String completeEarningTasksHint = 'Accept and complete rides to earn coins.';
  static const String collect100Coins = 'Collect 100 coins';
  static const String collect100CoinsHint = 'Reach 100 coins to unlock parcel delivery.';
  static const String startDeliveringParcels = 'Start delivering parcels';
  static const String startDeliveringParcelsHint =
      'Once eligible, you can receive parcel requests on your bike.';
  static const String earnByDeliveringParcels = 'Earn by delivering parcels with your eligible vehicles.';
  static const String yourVehicles = 'Your Vehicles';
  static const String canReceiveParcelRequests = 'Can receive parcel requests';
  static const String parcelNotAvailable = 'Parcel not available for this vehicle';
  static const String startReceivingParcelRequests = 'Start Receiving Parcel Requests';
  static const String vehicleCar = 'Car';
  static const String totalEarnings = 'Total Earnings';
  static const String incentives = 'Incentives';

  // ── Navigation / Ride ─────────────────────────────────────────
  static const String rideCancelled = 'Ride Cancelled';
  static const String rideCompleted = 'Ride Completed';
  static const String returnToHome = 'Return to Home';
  static const String pickup = 'Pickup';
  static const String dropoff = 'Drop-off';
  static const String customer = 'Customer';

  // ── Profile ───────────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String documents = 'Documents';
  static const String bankDetails = 'Bank Details';
  static const String vehicleDetails = 'Vehicle Details';
  static const String notSpecified = 'Not specified';

  // ── Errors ────────────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Check your connection.';
  static const String locationError = 'Unable to get location.';

  // ── Onboarding ────────────────────────────────────────────────
  static const String continueAction = 'Continue';
  static const String chooseLanguage = 'Choose your Language';
  static const String chooseLanguageSubtitle =
      'Select the language you prefer to continue with.';
  static const String selectLanguageError = 'Please select a language to continue.';
  static const String languageChangedLater =
      'Language can be changed later from settings';
  static const String welcome = 'Welcome';
  static const String welcomeSubtitle =
      "Enter your mobile number to begin, We'll verify the details automatically.";
  static const String enterMobileHint = 'Enter mobile number';
  static const String enterMobileError = 'Please enter a valid mobile number';
  static const String otpVerification = 'OTP Verification';
  static const String verifyYourNumber = 'Verify your number';
  static const String otpSentPrefix = 'Enter the OTP sent to ';
  static const String resendOtpIn = 'Resend OTP in ';
  static const String didntReceiveCode = "Didn't receive the code?";
  static const String resendOtp = 'Resend OTP';
  static const String verifyAndContinue = 'Verify & Continue';
  static const String changeMobileNumber = 'Change mobile number';
  static const String incorrectOtp =
      'Incorrect OTP. Please check the OTP and try again.';
  static const String selectVehicleCategory = 'Select Vehicle Category';
  static const String chooseVehicleType =
      'Choose the type of vehicle you will use for rides and deliveries.';
  static const String selectVehicleError = 'Please select a vehicle to continue.';
  static const String vehicleCab = 'Cab';
  static const String vehicleEvCab = 'EV Cab';
  static const String vehicleXlCab = 'XL Cab';
  static const String vehicleAuto = 'Auto';
  static const String vehicleBike = 'Bike';
  static const String fourWheeler = '4 Wheeler';
  static const String threeWheeler = '3 Wheeler';
  static const String twoWheeler = '2 Wheeler';
  static const String kycVerification = 'KYC Verification';
  static const String kycSubtitle =
      'Complete all required verification steps to become a Torkk driver.';
  static const String kycAadhaarPan = 'Aadhar + PAN';
  static const String kycDrivingLicense = 'Driving License';
  static const String kycVehicleRc = 'Vehicle RC';
  static const String kycVehiclePhotos = 'Vehicle Photos';
  static const String kycFaceVerification = 'Face Verification';
  static const String kycBankDetails = 'Bank Details';
  static const String kycProfileReview = 'Profile Review & Submission';
  static const String driversDetails = "Driver's Details";
  static const String uploadClearPhoto = 'Upload a clear photo';
  static const String fullName = 'Full Name';
  static const String gender = 'Gender';
  static const String genderMale = 'Male';
  static const String genderFemale = 'Female';
  static const String genderOther = 'Other';
  static const String dateOfBirth = 'Date of Birth';
  static const String dobFormatHint = 'dd-mm-yyyy';
  static const String emailOptional = 'Email (optional)';
  static const String continueToFinalReview = 'Continue to Final Review';
  static const String reviewYourDetails = 'Review your details';
  static const String personalDetails = 'Personal Details';
  static const String kycDocuments = 'KYC Documents';
  static const String emailAddress = 'Email Address';
  static const String driverDetailsRequired = 'Enter your name and date of birth to continue.';
  static const String kycVerified = 'Verified';
  static const String kycPending = 'Pending';
  static const String kycNotStarted = 'Not Started';
  static const String kycActivateHint =
      'Complete all steps to activate your driver account.';
  static const String verifyAadhaarPan = 'Verify Aadhaar & PAN';
  static const String verifyAadhaarSubtitle =
      'Your Aadhaar and PAN will be securely verified through DigiLocker.';
  static const String continueWithDigilocker = 'Continue with DigiLocker';
  static const String uploadManually = 'Upload Manually';
  static const String dataSafeWithUs = 'Your data is safe with us';
  static const String connectDigilocker = 'Connect DigiLocker';
  static const String connectDigilockerSubtitle =
      'DigiLocker will be used to retrieve and verify your required government documents';
  static const String documentsWellAccess = "DOCUMENTS WE'LL ACCESS";
  static const String aadhaarDoc = 'Aadhar';
  static const String panDoc = 'PAN';
  static const String drivingLicenseDoc = 'Driving License';
  static const String whereAvailable = '(where available)';
  static const String digilockerConsent =
      'I consent to Torkk accessing the required documents from DigiLocker for verification purposes.';
  static const String connectingDigilocker = 'Connecting to DigiLocker...';
  static const String connectingDigilockerSubtitle =
      'Please wait while we securely connect to your DigiLocker account.';
  static const String awaitingAuthentication = 'Awaiting authentication';
  static const String fetchingDocuments = 'Fetching your documents';
  static const String verifyingDocuments = 'Verifying your documents';
  static const String digilockerWaitHint =
      "This may take a few moment. Please don't close the app";
  static const String identityVerified = 'Identity Verified';
  static const String identityVerifiedSubtitle =
      'Your Aadhaar and PAN have been successfully verified through DigiLocker.';
  static const String documentsSecurelyVerified =
      'Your documents are securely verified through digilocker';
  static const String digilockerTitle = 'DigiLocker';
  static const String verificationFailed = 'Verification Failed';
  static const String verificationFailedSubtitle =
      "We couldn't verify your Aadhaar or PAN details.";
  static const String documentNotFound = 'Document Not Found';
  static const String documentNotFoundSubtitle =
      "We couldn't find the required document in your DigiLocker account.";
  static const String documentNotFoundHint =
      'Make sure the document is available in your DigiLocker account and try again.';
  static const String permissionDenied = 'Permission Denied';
  static const String permissionDeniedSubtitle =
      'DigiLocker permission was not granted. Please allow access to continue.';
  static const String permissionDeniedHint =
      'You need to give DigiLocker permission to access your documents securely.';
  static const String authenticationFailed = 'DigiLocker Authentication Failed';
  static const String authenticationFailedSubtitle =
      "We couldn't authenticate your DigiLocker account.";
  static const String authenticationFailedHint = 'Please check your credentials and try again.';
  static const String vehicleDocsWillBeVerified =
      'Vehicle RC, insurance and fitness certificate will be verified.';
  static const String retryVerification = 'Retry Verification';
  static const String tryAgain = 'Try Again';
  static const String useAnotherMethod = 'Use Another Method';
  static const String uploadManuallySubtitle =
      'Upload a clear photo of your Aadhaar to continue.';
  static const String aadhaarNumber = 'Aadhaar Number';
  static const String uploadAadhaarPhoto = 'Aadhaar photo';
  static const String panVerification = 'PAN Verification';
  static const String panNumber = 'PAN Number';
  static const String panGovHint = 'Your PAN will be verified with government records.';
  static const String verifyPan = 'Verify PAN';
  static const String aadhaarVerification = 'Aadhar Verification';
  static const String uploadYourAadhaar = 'Upload your Aadhar';
  static const String aadhaarCardNumber = 'Aadhar Card Number';
  static const String aadhaarGovHint = 'Your Aadhar will be verified with government records.';
  static const String verifyAadhaar = 'Verify Aadhar';
  static const String verifyDrivingLicence = 'Verify your Driving Licence';
  static const String verifyDrivingLicenceSubtitle =
      'Verify your valid Driving Licence to continue.';
  static const String verifyWithDigilocker = 'Verify with DigiLocker';
  static const String verifyWithDigilockerSubtitle =
      'Fast, secure and fetches your Driving Licence directly from DigiLocker.';
  static const String orWord = 'OR';
  static const String uploadDrivingLicense = 'Upload your Driving License';
  static const String frontSide = 'Front Side';
  static const String backSide = 'Back Side';
  static const String tapToUpload = 'Tap to upload';
  static const String drivingLicenceVerified = 'Driving Licence Verified';
  static const String drivingLicenceVerifiedSubtitle =
      'Your Driving License have been successfully verified through DigiLocker.';
  static const String drivingLicenseDetails = 'Driving License Details';
  static const String licenseNumber = 'License Number';
  static const String vehicleClass = 'Vehicle Class';
  static const String validity = 'Validity';
  static const String drivingLicenseTitle = 'Driving License';
  static const String preview = 'Preview';
  static const String retake = 'Retake';
  static const String expiryDate = 'Expiry Date';
  static const String verificationPending = 'Verification pending';
  static const String documentValidation = 'Document Validation';
  static const String documentUnclear = 'The document is unclear';
  static const String documentUnclearHint = 'Please capture a clear photo and try again.';
  static const String drivingLicenseVerifiedManual = 'Driving License Verified';
  static const String drivingLicenseVerifiedManualSubtitle =
      'Your driving licence has been successfully verified. You can proceed to the next step.';
  static const String drivingLicenseRejected = 'Driving License Rejected !';
  static const String drivingLicenseRejectedSubtitle =
      'We couldn\'t verify your driving licence. Please check the details and try again.';
  static const String rejectionReason = 'Reason';
  static const String documentImageUnclear = 'Document Image is Unclear';
  static const String documentImageUnclearHint =
      'The image does not meet our quality standards. Please upload a clear and readable version.';
  static const String fixAndResubmit = 'Fix & Resubmit';
  static const String drivingLicenseUnderReview = 'Driving License Under Review !';
  static const String drivingLicenseUnderReviewSubtitle =
      'Your driving licence is under review. This usually takes a few minutes to a few hours.';
  static const String blurryImage = 'Blurry Image';
  static const String blurryImageHint =
      'The image is not clear. Please retake a sharper photo and try again.';
  static const String verifyVehicleRc = 'Verify Vehicle RC';
  static const String verifyVehicleRcSubtitle =
      'Upload your vehicle Registration Certificate to verify the vehicle registered with Torkk.';
  static const String registrationNumber = 'Registration Number';
  static const String rcDocument = 'RC Document';
  static const String rcDocumentHint = 'Upload a clear photo of Registration Certificate';
  static const String rcClearHint =
      'Make sure the document is clear, readable and all details are visible.';
  static const String rcReadyHint = 'Your RC is ready for verification.';
  static const String rcUploaded = 'Uploaded';
  static const String replaceAction = 'Replace';
  static const String vehicleNumber = 'Vehicle number';
  static const String vehicleModel = 'Vehicle model';
  static const String vehicleType = 'Vehicle type';
  static const String insuranceExpiryDate = 'Insurance Expiry Date';
  static const String rcExtractedHint =
      'Vehicle details extracted from your RC document and verified.';
  static const String uploadVehiclePhoto = 'Upload your Vehicle Photo';
  static const String vehiclePhotos = 'Vehicle Photos';
  static const String vehiclePhotosSubtitle = 'Take photos of your vehicle';
  static const String captureFrontHint =
      'Capture the complete front of your vehicle. Make sure the vehicle and number plate are clearly visible.';
  static const String gallery = 'Gallery';
  static const String camera = 'Camera';
  static const String flip = 'Flip';
  static const String wrongImageUploaded = 'Wrong image uploaded';
  static const String wrongImageHint = 'Please check the image and try again.';
  static const String vehiclePhotosVerified = 'Vehicle Photos — Verified';
  static const String vehiclePhotosVerifiedSubtitle =
      'Both vehicle photos have been successfully verified.';
  static const String frontPhoto = 'Front Photo';
  static const String backPhoto = 'Back Photo';
  static const String actionRequiredPhotos = 'Action Required for Vehicle Photos';
  static const String actionRequiredPhotosHint =
      '1 Photo needs to be retaken. Please fix the issue below to continue.';
  static const String verificationFailedLabel = 'Verification Failed';
  static const String vehicleInsurance = 'Vehicle Insurance';
  static const String uploadInsurance = 'Upload your Insurance';
  static const String permitIfApplicable = 'Permit (if applicable)';
  static const String commercialPermit = 'Commercial Permit';
  static const String uploadPermit = 'Upload Permit Document';
  static const String bankPayoutDetails = 'Bank & Payout Details';
  static const String informationSecure = 'Your information is secure.';
  static const String accountHolderName = 'Account Holder Name';
  static const String accountNumber = 'Account Number';
  static const String confirmAccountNumber = 'Confirm Account Number';
  static const String ifscCode = 'IFSC Code';
  static const String findIfsc = 'Find IFSC';
  static const String bankName = 'Bank Name';
  static const String updateDetails = 'Update details';
  static const String saveAndVerify = 'Save & Verify';
  static const String verifyingBank = 'Verifying your bank details';
  static const String verifyingBankSubtitle =
      'Please wait while we verify your bank account with our secure partner.';
  static const String bankDetailsSubmitted = 'Bank details submitted';
  static const String verifyingAccountWithBank = 'Verifying account with bank';
  static const String bankVerifyWait = 'This may take a few seconds...';
  static const String confirmingAccountDetails = 'Confirming account details';
  static const String bankEncryptedHint = 'Your details are encrypted and securely verified.';
  static const String bankDetailsVerified = 'Bank details verified';
  static const String bankDetailsVerifiedSubtitle =
      'Your bank account has been successfully verified and linked to your Torkk account.';
  static const String bankAccountDetails = 'Bank Account Details';
  static const String bankReadyHint = 'Your bank account is verified and ready to receive payments.';
  static const String bankVerificationFailed = 'Bank Verification Failed';
  static const String bankVerificationFailedSubtitle =
      "We couldn't verify your bank account. Please check the details and try again.";
  static const String reason = 'Reason';
  static const String incorrectAccountOrIfsc = 'Incorrect account number or IFSC';
  static const String accountInactive = 'Account is inactive';
  static const String verifyYourIdentity = 'Verify your identity';
  static const String verifyIdentitySubtitle = 'Take a quick selfie to confirm your identity';
  static const String identityRealPerson = 'Helps us confirm that you are a real person';
  static const String identityRequired = 'Required to complete your onboarding';
  static const String identityQuick = 'Takes less than a minute';
  static const String startFaceVerification = 'Start Face Verification';
  static const String beforeYouStart = 'Before you start';
  static const String beforeYouStartSubtitle = 'Follow these simple steps to get the best result.';
  static const String faceInFrame = 'Position your face inside the frame.';
  static const String faceVisible = 'Make sure your face is clearly visible.';
  static const String removeCoverings = 'Remove your helmet, sunglasses, mask or anything covering your face.';
  static const String wellLit = 'Make sure you are in a well-lit area.';
  static const String allowCameraAccess = 'Allow Camera Access';
  static const String allowCameraSubtitle =
      'We need access to your camera to verify your identity.';
  static const String dataSafeSecure = 'Your data is safe and secure';
  static const String usedOnlyForIdentity = 'Used only for identity verification';
  static const String photoNotStored = 'We do not store your photo after verification';
  static const String faceDetected = 'Face Detected';
  static const String noFaceDetected = 'No Face Detected';
  static const String verifyingYourFace = 'Verifying your face';
  static const String verifyingFaceSubtitle = 'Please wait while we verify your identity.';
  static const String photoCaptured = 'Photo captured';
  static const String analyzingFace = 'Analyzing face';
  static const String checkingLiveness = 'Checking liveness';
  static const String finalizingVerification = 'Finalizing verification';
  static const String identityVerifiedFace = 'Identity verified';
  static const String identityVerifiedFaceSubtitle = 'Your face has been successfully verified.';
  static const String identityConfirmed = 'Identity confirmed';
  static const String accountSecured = 'Account secured';
  static const String completeOnboardingNow = 'You can now complete your onboarding';
  static const String faceVerificationFailed = 'Face Verification Failed';
  static const String faceVerificationFailedSubtitle =
      "We couldn't verify your identity. Please try again in good lighting.";
  static const String faceNotDetectedReason = 'Face not detected';
  static const String faceNotDetectedHint =
      'Make sure you are looking at the camera and your face is inside the frame.';
  static const String otpSentTitle = 'OTP sent';
  static const String otpSentMessage = 'OTP sent successfully.';
  static const String termsPrefix = 'By continuing, you agree to our ';
  static const String termsOfService = 'Terms of Service';
  static const String andWord = ' and ';
  static const String tagline = 'Earn Fair. Drive Safe';
  static const String english = 'English';
  static const String englishSubtitle = 'Click here to select english';
  static const String hindi = 'हिंदी';
  static const String hindiSubtitle = 'हिंदी चुनने के लिए यहाँ क्लिक करें';
  static const String countryCodeIndia = '+91';
  static const String phoneHint = '00000 00000';
  static const String agreeWith = 'I agree with ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String driverAgreement = 'Driver Agreement';
  static const String applicationSubmitted = 'Application Submitted';
  static const String applicationSubmittedSubtitle =
      'Thankyou ! Your application has been\nsubmitted successfully';
  static const String applicationApproved = 'Application Approved';
  static const String applicationApprovedSubtitle =
      'Welcome to Torkk !\nYou can now start driving and earning.';
  static const String currentStatus = 'Current Status';
  static const String underReview = 'Under Review';
  static const String underReviewHint =
      'We are verifying your details. This usually takes 1-2 business days';
  static const String applicationApprovedStatus = 'Approved';
  static const String applicationApprovedHint =
      'Your documents are verified and your account is active.';
  static const String applicationSubmittedStep = 'Application submitted';
  static const String underReviewStep = 'Under review';
  static const String underReviewNotify = "We'll notify you once it's approved";
  static const String startDrivingWithTorkk = 'Start driving with Torkk';
  static const String goHome = 'Go Home';
  static const String actionRequired = 'Action Required';
  static const String actionRequiredSubtitle =
      "We couldn't approve your application yet.\nPlease review the details below.";
  static const String applicationRejected = 'Application Rejected';
  static const String applicationRejectedSubtitle =
      "We couldn't approve your application.\nReview it for approval";
  static const String actionRequiredBanner =
      'Some of your documents could not be verified. Please check and resubmit.';
  static const String documentsNeedAttention = 'Documents need attention';
  static const String documentsNeedAttentionHint =
      'Please review your documents and upload a clear image.';
  static const String uploadAndResubmit = 'Upload & Resubmit';
  static const String makeCorrections = 'Make Corrections';
}
