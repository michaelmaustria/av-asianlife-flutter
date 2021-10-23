import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class DataPrivacyPage extends StatefulWidget {
  final bool isGranted;

  DataPrivacyPage(this.isGranted);

  @override
  _DataPrivacyPageState createState() => _DataPrivacyPageState();
}

class _DataPrivacyPageState extends State<DataPrivacyPage> {

  double _height, _width;
  bool checkBoxValue;
  Matrix4 matrix = Matrix4.identity();
  Matrix4 zerada =  Matrix4.identity();

  @override
  void initState() {
    super.initState();
    checkBoxValue = widget.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    _height = MediaQuery.of(context).size.height * .85;
    _width = MediaQuery.of(context).size.width;

    Widget _getText(String text) {
      return Text(text, textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 14.0));
    }

    TextStyle style = TextStyle(
            inherit: true,
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
            decorationColor: Colors.black87,
            decorationStyle: TextDecorationStyle.solid,
            color: Colors.black87);

    return GestureDetector(
      onDoubleTap: (){
        setState(() {
          matrix = zerada;
        });
      },
      child: MatrixGestureDetector(
        shouldRotate: false,
        onMatrixUpdate: (m, tm, sm, rm){
          matrix = m;
          notifier.value = matrix;
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child){
            return Transform(
              transform: notifier.value,
              child: Container(
      height: _height,
      width: _width,
      child: Stack(
        children: <Widget>[
          Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: Text('Data Privacy Consent'),
              ),
              body: DefaultTextStyle(
                style: style,
                child: Container(
                  height: _height,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: _height * .85,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              _getText('Etiqa Life and General Assurance Philippines, Inc. (Etiqa Philippines), formerly AsianLife and General Assurance Corporation, a life and non-life insurance company provides a wide range of products including Group Health and Accident Insurance, Group Life, Individual Insurance, Micro-Insurance, Motor, Fire, Travel and Construction All-Risk Insurance. Over the years, it has built a solid reputation for fast, prompt and reliable service and is now considered a leader in employee benefits insurance insuring executives, employees and dependents of multinational and local corporations nationwide. Etiqa Philippines also offers loans to educators. We at Etiqa Philippines are committed to provide you with the services pursuant to the service/product agreements to which we are parties while implementing safeguards to protect your privacy and keep your personal data safe and secure. '),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Processing of Personal Data. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'The types of personal data we collect may include, but is not limited to your name, address, other contact details, age, date of birth, occupation, marital status, place of birth, financial references (e.g. income, tax particulars, credit history), information on personal identifiers (e.g. identity card, passport), professional information (e.g. specialization, clinic schedules), medical conditions and diagnosis and your transaction history.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              _getText('If you are supplying personal data of other parties such as your family members, legal guardians, nominees, directors, shareholders, please do ensure that you have obtained their consent and bring this consent form to their attention.'),
                              SizedBox(height: 10.0,),
                              _getText('If you are a beneficiary/dependent and not a policyholder/member, we will only process your personal data for purposes relating to administering the insurance policy/contract.'),
                              SizedBox(height: 10.0,),
                              _getText('We may process your personal data for the following reasons:'),
                              Container(
                                padding: const EdgeInsetsDirectional.only(start: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _getText('1. To assess your application for any of our products and services or to continue provisioning the products and/or services (whichever is applicable).'),
                                    _getText('2. To administer your insurance policy/contract/loan and any claims made against your policy/contract or settlement of your loan or any other transaction related to the product/service which you availed.'),
                                    _getText('3. To manage and maintain your account with Etiqa Philippines.'),
                                    _getText('4. To continue performing the contractual obligations entered into between Etiqa Philippines and you/your representative.'),
                                    _getText('5. To respond to your inquiries and complaints and to resolve disputes.'),
                                    _getText('6. For internal functions such as evaluating the effectiveness of marketing, market research, statistical analysis and modelling, reporting, audit and risk management and to prevent fraud from time to time.'),
                                    _getText('7. To provide you with information on products and/or services of Etiqa Philippines. '),
                                    _getText('8. To prevent fraud or detect crime for the purpose of investigation.'),
                                    _getText('9. For security reasons, in particular personal data collected from close circuit security surveillance cameras.'),
                                    _getText('10. For any purpose required by law or regulations (e.g. Anti-Money Laundering Law, Credit Information System Act, Foreign Account Tax Compliance Act). In this regard, your personal data may be furnished the relevant government agency (e.g. Insurance Commission, Credit Information Corporation, Anti-Money Laundering Council).'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Data Protection. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'We shall implement reasonable and appropriate organizational, physical and technical security measures for the protection of personal data which we collected. The security measures shall aim to maintain the availability, integrity and confidentiality of personal data and are intended for the protection or personal data against any accidental or unlawful destruction, alteration, disclosure, as well as against any unlawful processing.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Confidentiality. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'Our employees shall operate and hold personal data under strict confidentiality. They are required to sign non-disclosure agreements and have received training on the company’s privacy and security policies to ensure confidentiality and security of personal data.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Disclosures to 3rd Parties. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'From time to time, we may share your personal data with “Other Entities” (e.g. our/you/your employer and/or your employer’s agents/brokers, strategic partners, network providers, reinsurers, mother company, subsidiaries, affiliates, auditors, professional consultants, banks, financial institutions and other similar third parties) as Etiqa Philippines deems fit and in order to better serve your account. You may also receive marketing communication from us about products and services that may be of interest to you. If you no longer wish to receive these marketing communication, please notify us and we will stop processing your personal data for the purpose of sending you marketing communications. If you would like to withdraw consent for marketing and promotional materials, you may contact us using the contact details found below. Please be aware that once we receive confirmation that you wish to withdraw your consent for marketing or promotional materials, it may take up to seven (7) days for your withdrawal to be reflected in our systems. Therefore, you may still receive marketing or promotional materials during this period of time.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              _getText('If you are an accredited network provider, your personal data shall be shared with Etiqa Philippines Clients and published for use of the general public.'),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Rights of the Data Subjects. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'You are entitled to the following rights:'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Container(
                                padding: const EdgeInsetsDirectional.only(start: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _getText('1. Be informed on whether your personal information shall be, are being or have been processed.'),
                                    _getText('2. Be furnished with the information indicated below before the entry of your personal information into the processing system of the personal information controller or at the next practical opportunity: (a) Description of the personal information to be entered into the system (b) Purposes for which they are being or are to be processed (c) Scope and method of the personal information processing (d) Recipients or classes of recipients to who, they are or may be disclosed (e) Methods utilized for automated access, if the same is allowed by the data and the extent to which such access is authorized (f) Identity and contact details of the personal information controller or its representative (g) Period for which the information will be stored (h) Existence of their rights, i.e. to access, correction, as well as the right to lodge a complaint before the National Privacy Commission.Any information supplied and declaration made to you on these matters shall not be amended without prior notification: Provided, that the notification under subsection (2) shall not apply should the personal information be needed pursuant to a subpoena or when the collection of processing are for obvious purposes, including when it is necessary for the performance of or in relation to a contract or service or when necessary and desirable in the context of an employer-employee relationship, or when the information is being collected and processed as a result of a legal obligation.'),
                                    _getText('3. Reasonable access to, upon demand, the following: (a) Contents of your personal information that were processed (b) Sources from which personal information were obtained (c) Names and addresses of recipients of the personal information (d) Manner by which such data were processed (e) Reasons for the disclosure of the personal information to recipients (f) Information on automated processes where the data will likely to be made as the sole basis for any decision significantly affecting or will affect you (g) Date when your personal information was last accessed and modified (h) The designation, name or identity and address of the personal information controller.'),
                                    _getText('4. Dispute the inaccuracy or error in the personal information and have the personal information controller correct it immediately and accordingly, unless the request is vexatious or otherwise unreasonable. If the personal information has been corrected, the personal information controller shall ensure the accessibility of both the new and retracted information and the simultaneous receipt of the new and retracted information by the recipients thereof; Provided, that third parties who have previously received such processed personal information shall be informed of its inaccuracy and its rectification upon your request.'),
                                    _getText('5. Suspend, withdraw or order the blocking, removal or destruction of your personal information from the personal information controller’s filing system upon discovery and substantial proof that the personal information are incomplete, outdated, false, unlawfully obtained , used for unauthorized purposes or are no longer necessary for the purposes for which they were collected.'),
                                    _getText('6. Be indemnified for any damages sustained due to such inaccurate, incomplete, outdated, and false, unlawfully obtained or unauthorized use of personal information.'),
                                    _getText('7. Right to data portability – where personal information is processed by electronic means and in a structured and commonly used format, you have the right to obtain from the personal information controller a copy of the data undergoing processing in an electronic or structured format, which is commonly used and allows for further use.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Inquiries. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'If you have further questions or concerns, you may contact our Data Protection Officer through the following details:'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Container(
                                width: _width,
                                padding: const EdgeInsetsDirectional.only(start: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _getText('1. Contact Number: +632 8890-1758'),
                                    _getText('2. Email Address: compliance@etiqa.com.ph'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Personal Information Controller. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'The personal information controller is the President and Chief Executive Officer:'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Container(
                                width: _width,
                                padding: const EdgeInsetsDirectional.only(start: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _getText('1. Contact Number: +632 8890-1758'),
                                    _getText('2. Business Address: 3F Morning Star Center 347 Sen. Gil Puyat Ave. Makati City 1209.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  style: style,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Expiry. ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'This consent to process and disclose shall be valid until my account/accreditation is active/policy in force/service agreement is effective/loan agreement outstanding and the like. However, this consent may be revoked any time before expiration:'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              _getText('I have read this form, understood its contents and consent to the processing and disclosure of my personal data. I understand that my consent does not preclude the existence of other criteria for lawful processing of personal data and does not waive any of my rights under the Data Privacy Act of 2012 and other applicable laws.'),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Checkbox(
                                      value: checkBoxValue,
                                      activeColor: mPrimaryColor,
                                      onChanged:(bool newValue){
                                        setState(() {
                                          checkBoxValue = newValue;
                                        });
                                      }),
                                  Expanded(
                                      child: Text('Please tap checkbox to agree.',
                                        maxLines: 2,
                                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),)
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: _width * .5,
                        child: RaisedButton(
                          padding: EdgeInsets.all(10),
                          color: mPrimaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          child: Text('Continue', style: TextStyle(color: Colors.black87)),
                          //onPressed: _isInteractionDisabled ? null : _validateInputs,
                          onPressed: checkBoxValue ?
                              () => Navigator.pop(context, 'granted') : null,
                        ),
                      ),

                      Align(
                          alignment: Alignment.bottomCenter,
                          child: copyRightText()
                      ),
                    ],
                  ),
                ),
              )
          ),
        ],
      ),
    )
            );
          },
        ),
      ),
    );
  }
}
