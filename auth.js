// ======================
// LOGOUT FUNCTION
// ======================
function logout() {
    localStorage.removeItem("loggedUser");
    window.location.href = "login.html";
}


// ======================
// AUTO CLEAN EXPIRED USERS (7 DAYS)
// ======================
function cleanExpiredUsers() {
    let users = JSON.parse(localStorage.getItem("users")) || {};
    let currentTime = new Date().getTime();

    for (let user in users) {
        if (users[user].expiry && users[user].expiry < currentTime) {
            delete users[user];
        }
    }

    localStorage.setItem("users", JSON.stringify(users));
}


// ======================
// CHECK LOGIN SESSION
// ======================
function checkLogin() {
    let loggedUser = localStorage.getItem("loggedUser");

    if (!loggedUser) {
        window.location.href = "login.html";
    }
}


// ======================
// RUN ON EVERY PAGE LOAD
// ======================
window.onload = function () {
    cleanExpiredUsers();
    checkLogin();
};
function logout() {
    localStorage.removeItem("loggedUser");
    window.location.href = "login.html";
}