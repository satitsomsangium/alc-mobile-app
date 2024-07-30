import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'นโยบายความเป็นส่วนตัว',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSection(
                'Privacy Policy',
                'Satit Somsangium built the ALC Mobile app as a Free app. This SERVICE is provided by Satit Somsangium at no cost and is intended for use as is.\n\nThis page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.\n\nIf you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at ALC Mobile unless otherwise defined in this Privacy Policy.',
              ),
              _buildSectionWithLink(
                'Information Collection and Use',
                'For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to Camera. The information that I request will be retained on your device and is not collected by me in any way.\n\nThe app does use third party services that may collect information used to identify you.\n\nLink to privacy policy of third party service providers used by the app',
                'https://policies.google.com/privacy',
                'Google Play Services',
              ),
              _buildSection(
                'Log Data',
                'I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.',
              ),
              _buildSection(
                'Cookies',
                "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.\n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.",
              ),
              _buildSection(
                'Service Providers',
                "I may employ third-party companies and individuals due to the following reasons:\n\n    - To facilitate our Service;\n    - To provide the Service on our behalf;\n    - To perform Service-related services; or\n    - To assist us in analyzing how our Service is used.\n\nI want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
              ),
              _buildSection(
                'Security',
                "I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.",
              ),
              _buildSection(
                'Links to Other Sites',
                "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.",
              ),
              _buildSection(
                'Children’s Privacy',
                "These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13 years of age. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions.",
              ),
              _buildSection(
                'Changes to This Privacy Policy',
                "I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page.\n\n This policy is effective as of 2021-03-28",
              ),
              _buildSection(
                'Contact Us',
                "If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at satitsomsangium@gmail.com.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(color: Colors.black87)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionWithLink(
      String title, String content, String url, String linkText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(color: Colors.black87)),
        Align(
          alignment: Alignment.topLeft,
          child: Link(
            uri: Uri.parse(url),
            target: LinkTarget.blank,
            builder: (ctx, openLink) {
              return TextButton.icon(
                onPressed: openLink,
                label: Text(linkText),
                icon: const Icon(
                  Icons.circle_rounded,
                  size: 10,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}