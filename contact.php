<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . '/vendor/autoload.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    exit("Méthode non autorisée.");
}

$name = trim($_POST["name"] ?? "");
$email = trim($_POST["email"] ?? "");
$message = trim($_POST["message"] ?? "");

if ($name === "" || $email === "" || $message === "") {
    exit("Veuillez remplir tous les champs.");
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    exit("Adresse email invalide.");
}

/*
 * Chargement du fichier .env
 */

$envFile = __DIR__ . "/.env";

if (!file_exists($envFile)) {
    exit("Configuration SMTP introuvable.");
}

$env = parse_ini_file($envFile);

if ($env === false) {
    exit("Impossible de lire la configuration SMTP.");
}

$smtpHost = $env["SMTP_HOST"] ?? "";
$smtpPort = (int) ($env["SMTP_PORT"] ?? 587);
$smtpUsername = $env["SMTP_USERNAME"] ?? "";
$smtpPassword = $env["SMTP_PASSWORD"] ?? "";
$smtpFrom = $env["SMTP_FROM"] ?? "";
$smtpTo = $env["SMTP_TO"] ?? "";

if (
    $smtpHost === "" ||
    $smtpUsername === "" ||
    $smtpPassword === "" ||
    $smtpFrom === "" ||
    $smtpTo === ""
) {
    exit("Configuration SMTP incomplète.");
}

$mail = new PHPMailer(true);

try {

    $mail->isSMTP();

    $mail->Host = $smtpHost;
    $mail->SMTPAuth = true;
    $mail->Username = $smtpUsername;
    $mail->Password = $smtpPassword;

    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = $smtpPort;

    $mail->CharSet = "UTF-8";

    $mail->setFrom($smtpFrom, "Honey Group");
    $mail->addAddress($smtpTo);

    $mail->addReplyTo($email, $name);

    $mail->Subject = "Nouveau message depuis le site Honey Group";

    $mail->Body =
        "Nouveau message reçu depuis le formulaire de contact.\n\n" .
        "Nom : " . $name . "\n" .
        "Email : " . $email . "\n\n" .
        "Message :\n" .
        $message;

    $mail->send();

    /*
     * Enregistrement local du message
     */

    $date = date("Y-m-d H:i:s");

    $content =
        "==============================\n" .
        "Date : " . $date . "\n" .
        "Nom : " . $name . "\n" .
        "Email : " . $email . "\n" .
        "Message :\n" .
        $message . "\n" .
        "==============================\n\n";

    file_put_contents(
        __DIR__ . "/messages.txt",
        $content,
        FILE_APPEND | LOCK_EX
    );
header("Location: pages/contact.html?sent=1");
exit;
} catch (Exception $e) {

    http_response_code(500);

    echo "Erreur lors de l'envoi du message.";

}

?>
