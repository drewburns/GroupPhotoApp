const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


exports.addAccount = functions.auth.user().onCreate(event => {
	const user = event.data; // The firebase user
	const user_id = user.uid;
	const welcomeImageKey1 = "-L4OZHwtWXJ62YceNPBo"
	const welcomeImageKey2 = "-L4OZHqnjRGW9pSoiC50"
	const welcomeImageKey3 = "-L4OZHqUarK271H0PLEf"


	console.log("Got user data");
	var promises = [];
	var newGroup = admin.database().ref("groups").push(); 
	console.log("Pushed a new group kinda???");

	var timestamp = Math.floor(Date.now()/1000)
	console.log(timestamp)
	newGroup.set({
	  'name': 'Welcome!',
	  'timestamp': timestamp
	});
	console.log("Made a new group")
	var keystring = newGroup.key

	var fields = keystring.split('/');

	var key = fields[fields.length - 1]
	console.log(key)

	var newGroupUser = admin.database().ref(`group-users/${key}`)
	newGroupUser.set({[user_id]: 0});
	promises.push(newGroupUser);
	console.log("newGroupUser")
	console.log(promises)



	var newUserGroup = admin.database().ref(`user-groups/${user_id}`)
	newUserGroup.set({ [key]: 0});
	promises.push(newUserGroup);
	console.log("newUserGroup")
	console.log(promises)

	var newUserAsset1 = admin.database().ref(`user-assets/${user_id}`)
	newUserAsset.set({ [welcomeImageKey3]: 0});
	promises.push(newUserAsset1);
	console.log("newUserAsset")
	console.log(promises)

	var newGroupAsset1 = admin.database().ref(`group-assets/${key}`)
	newGroupAsset.set({[welcomeImageKey3]: 0});
	promises.push(newGroupAsset1);
	console.log("newGroupAsset")
	console.log(promises)

		var newUserAsset2 = admin.database().ref(`user-assets/${user_id}`)
	newUserAsset.set({ [welcomeImageKey2]: 0});
	promises.push(newUserAsset2);
	console.log("newUserAsset")
	console.log(promises)

	var newGroupAsset2 = admin.database().ref(`group-assets/${key}`)
	newGroupAsset.set({[welcomeImageKey2]: 0});
	promises.push(newGroupAsset2);
	console.log("newGroupAsset")
	console.log(promises)

		var newUserAsset3 = admin.database().ref(`user-assets/${user_id}`)
	newUserAsset.set({ [welcomeImageKey1]: 0});
	promises.push(newUserAsset3);
	console.log("newUserAsset")
	console.log(promises)

	var newGroupAsset3 = admin.database().ref(`group-assets/${key}`)
	newGroupAsset.set({[welcomeImageKey1]: 0});
	promises.push(newGroupAsset3);
	console.log("newGroupAsset")
	console.log(promises)

	return Promise.all(promises);

});

function timeMil(){
    var date = new Date();
    var timeMil = date.getTime();

    return timeMil;
}

exports.updateTimestamp = functions.database.ref('/group-assets/{group-id}').onWrite(event => {
	const data = event.data
	var promises = [];
	// var timestamp = Math.floor(admin.database.ServerValue.TIMESTAMP/1000)
	var key = data.key;

	var updateRef = admin.database().ref(`groups/${key}/timestamp`);
	updateRef.set(Math.floor(timeMil()/1000));
	promises.push(updateRef);


	return Promise.all(promises);
	// admin.database.ServerValue.TIMESTAMP

	// const key = event.ref
});
// exports.ObserveProposals = functions.database.ref("/proposals/{jobid}/{propid}").onWrite((event) => {
//     const jobid = event.params.jobid;
//     const userid = event.params.propid;
//     const promises = [];
//     let userRef = admin.database().ref(`users/${userid}/proposals`);
//     let jobRef = admin.database().ref(`/jobs/${jobid}/proposals`);
//     jobRef.once('value').then(snapshot => {
//         if (snapshot.val() !== null) {
//             jobRef.transaction(current => {
//                 if (event.data.exists() && !event.data.previous.exists()) {
//                     return (current || 0) + 1;
//                 } else if (!event.data.exists() && event.data.previous.exists()) {
//                     return (current || 0) - 1;
//                 }
//             });
//         }
//     });
//     promises.push(jobRef);
//     if (event.data.exists() && !event.data.previous.exists()) {
//         const isInvitation = event.data.child("isinvitation").val();
//         if (!isInvitation) {
//             return userRef.child(`/sent/${jobid}`).set({
//                 timestamp: admin.database.ServerValue.TIMESTAMP
//             });
//         } else if (isInvitation) {
//             return userRef.child(`/received/${jobid}`).set({
//                 timestamp: admin.database.ServerValue.TIMESTAMP
//             });
//         }
//     } else if (!event.data.exists() && event.data.previous.exists()) {
//         const isInvitation = event.data.previous.child("isinvitation").val();
//         if (!isInvitation) {
//             return userRef.child(`/sent/${jobid}`).remove();
//         }else if (isInvitation) {
//             return userRef.child(`/received/${jobid}`).remove();
//         }
//     }
//     promises.push(userRef);
//     return Promise.all(promises);
// });