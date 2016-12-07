// userDb.js
// ------------------------------------------------------------------
//
// This is a mock user validation database. The hash stores usernames and
// the hex-encoded sha256 of the passwords, as well as roles for the users.
//
// To generate additional sha256 passwords on macosx:
//
//   echo -n "password-value" | shasum -a 256
//
// This is a little bit elaborate for a fake user authentication system.
// I just wanted to show some of the things that could be done in a JS callout.
//
// -Dino
//
// created: Fri Mar 25 20:01:12 2016
// last saved: <2016-December-06 22:52:19>

var userDb = {
      kdanekind : { // I-love-APIs123
        hash: '79809c4f1a43567bd5280b4bd2a9dc6f136f947e684b9a9632f4003afb927c38',
        roles: ['read', 'edit', 'delete']
      },
      dchiesa : { // GoDigital
        hash: 'f5ff9dc55cf345c5becee2a372cd8395ee4d5d25a5cd81ebde6f59ffa9f5578b',
        roles: ['read']
      },
      alanho: { // 123Secure
        hash : 'dd213871d6b955ae8c61690dab3615946b2d4be338518afdd5ae9464fc7982c8',
        roles: ['read']
      },
      mjmclaren : { // Protection0
        hash: '17cf5cf5994fc6b917b14cc62a73e6e6ce1074fc575516278bb283e03480c229',
        roles : ['read', 'edit']
      },
      paullee : { // CAVA-Rules
        hash: '6a680219d9ffb2acfa315dc13fdd0ea9dde019b0f84e1f190ef50cb8f9ee8871',
        roles : ['read', 'edit']
      }

      // Obviously, you can add more records here.
      // Also, you can add other properties to each record. For example, beyond
      // roles, you could add 'defaultProvider' or whatever else makes sense
      // in your desired system. If you DO add other data items, then
      // you would also need to modify the proxy to attach those properties to
      // a token issued by Edge.
      //
      // Follow the example in the GenerateAccessToken policy for the roles.

    };
