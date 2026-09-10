document.addEventListener("DOMContentLoaded", function () {

    loadComponent("navbar", "components/navbar.html");
    loadComponent("hero", "components/hero.html");
    loadComponent("footer", "components/footer.html");

    loadServices();
    loadServiceDetail();

});


/* =========================================================
   CHARGEMENT DES COMPOSANTS
   ========================================================= */

function loadComponent(elementId, file) {

    const element = document.getElementById(elementId);

    if (!element) {
        return;
    }

    const basePath = window.location.pathname.includes("/pages/")
        ? "../"
        : "";

    fetch(basePath + file)
        .then(response => {

            if (!response.ok) {
                throw new Error(
                    "Impossible de charger : " + basePath + file
                );
            }

            return response.text();

        })
        .then(content => {

            element.innerHTML = content;


            /* =========================
               NAVBAR
               ========================= */

            if (elementId === "navbar") {

                const siteName = document.getElementById("site-name");

                if (
                    siteName &&
                    typeof siteContent !== "undefined" &&
                    siteContent.site
                ) {
                    siteName.textContent =
                        siteContent.site.name;
                }

                setupNavigation();
            }


            /* =========================
               HERO
               ========================= */

            if (elementId === "hero") {

                if (
                    typeof siteContent !== "undefined" &&
                    siteContent.hero
                ) {

                    const label =
                        document.querySelector(".hero-label");

                    const title =
                        document.querySelector(".hero h1");

                    const description =
                        document.querySelector(".hero-description");


                    if (label) {
                        label.textContent =
                            siteContent.hero.label;
                    }


                    if (title) {
                        title.textContent =
                            siteContent.hero.title;
                    }


                    if (description) {
                        description.textContent =
                            siteContent.hero.description;
                    }

                }

            }


            /* =========================
               FOOTER
               ========================= */

            if (elementId === "footer") {

                const footerSiteName =
                    document.getElementById("footer-site-name");

                if (
                    footerSiteName &&
                    typeof siteContent !== "undefined" &&
                    siteContent.site
                ) {
                    footerSiteName.textContent =
                        siteContent.site.name;
                }

            }

        })
        .catch(error => {

            console.error(error);

            element.innerHTML =
                "<p>Erreur lors du chargement du composant.</p>";

        });

}


/* =========================================================
   NAVIGATION
   ========================================================= */

function setupNavigation() {

    const basePath =
        window.location.pathname.includes("/pages/")
            ? "../"
            : "";


    const links =
        document.querySelectorAll("[data-page]");


    links.forEach(link => {

        const page = link.dataset.page;


        if (page === "home") {

            link.href =
                `${basePath}index.html`;

        }


        if (page === "about") {

            link.href =
                `${basePath}pages/about.html`;

        }


        if (page === "services") {

            link.href =
                `${basePath}pages/services.html`;

        }


        if (page === "projects") {

            link.href =
                `${basePath}pages/projects.html`;

        }


        if (page === "contact") {

            link.href =
                `${basePath}pages/contact.html`;

        }

    });

}


/* =========================================================
   AFFICHAGE DES SERVICES
   ========================================================= */

function loadServices() {

    const container =
        document.getElementById("services-container");


    if (!container) {

        console.log(
            "services-container introuvable"
        );

        return;

    }


    if (typeof siteContent === "undefined") {

        console.error(
            "siteContent est introuvable"
        );

        return;

    }


    if (!siteContent.services) {

        console.error(
            "Aucun service trouvé"
        );

        return;

    }


    container.innerHTML = "";


    const basePath =
        window.location.pathname.includes("/pages/")
            ? "../"
            : "";


    siteContent.services.forEach(service => {


        const card =
            document.createElement("article");


        card.className = "card";


        card.innerHTML = `

            <h3>
                ${service.title}
            </h3>

            <p>
                ${service.description}
            </p>

            <a
                href="${basePath}pages/service-detail.html?service=${service.id}"
                class="btn btn-secondary"
            >
                ${service.button}
            </a>

        `;


        container.appendChild(card);

    });

}


/* =========================================================
   PAGE DETAIL D'UN SERVICE
   ========================================================= */

function loadServiceDetail() {

    const title =
        document.getElementById("service-title");


    /*
     * Si on n'est pas sur la page
     * service-detail.html, on arrête.
     */

    if (!title) {
        return;
    }


    if (typeof siteContent === "undefined") {

        console.error(
            "siteContent est introuvable"
        );

        return;

    }


    const params =
        new URLSearchParams(
            window.location.search
        );


    const serviceId =
        params.get("service");


    /*
     * Si aucun service n'est indiqué
     */

    if (!serviceId) {

        showServiceNotFound();

        return;

    }


    /*
     * Recherche du service
     */

    const service =
        siteContent.services.find(
            item => item.id === serviceId
        );


    /*
     * Service inexistant
     */

    if (!service) {

        showServiceNotFound();

        return;

    }


    /*
     * Récupération des éléments HTML
     */

    const label =
        document.getElementById("service-label");


    const description =
        document.getElementById(
            "service-description"
        );


    const details =
        document.getElementById(
            "service-details"
        );


    /*
     * Remplissage du contenu
     */

    if (label) {

        label.textContent =
            "Service";

    }


    if (title) {

        title.textContent =
            service.title;

    }


    if (description) {

        description.textContent =
            service.description;

    }


    if (details) {

        details.textContent =
            service.details;

    }


    /*
     * Modification du titre
     * de l'onglet du navigateur
     */

    document.title =
        `${service.title} - Honey Group`;

}


/* =========================================================
   SERVICE INTROUVABLE
   ========================================================= */

function showServiceNotFound() {

    const label =
        document.getElementById(
            "service-label"
        );


    const title =
        document.getElementById(
            "service-title"
        );


    const description =
        document.getElementById(
            "service-description"
        );


    const details =
        document.getElementById(
            "service-details"
        );


    if (label) {

        label.textContent =
            "Erreur";

    }


    if (title) {

        title.textContent =
            "Service introuvable";

    }


    if (description) {

        description.textContent =
            "Le service demandé n'existe pas.";

    }


    if (details) {

        details.textContent =
            "Veuillez retourner à la page des services et sélectionner un service disponible.";

    }


    document.title =
        "Service introuvable - Honey Group";

}