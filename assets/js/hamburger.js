const hamburger = document.querySelector("[data-menu-toggle]");
const navMenu = document.querySelector("#navbar-main-menu");

// Add eventlistener, hide close button
hamburger.addEventListener("click", mobileMenu);
document.getElementById("toggle-icon-menu").style.display = "inline";
document.getElementById("toggle-icon-close").style.display = "none";

function mobileMenu() {
    hamburger.classList.toggle("active");
    navMenu.classList.toggle("active");
    if (hamburger.classList.contains("active")) { //we switched on
        document.getElementById("toggle-icon-menu").style.display = "none";
        document.getElementById("toggle-icon-close").style.display = "inline";
    } else { // We switched off
        document.getElementById("toggle-icon-menu").style.display = "inline";
        document.getElementById("toggle-icon-close").style.display = "none";
    }
}
// Since mine a links not JS, not sure this is necessary...
const navLink = document.querySelectorAll(".nav-link");
navLink.forEach(n => n.addEventListener("click", closeMenu));
function closeMenu() {
    hamburger.classList.remove("active");
    navMenu.classList.remove("active");
}