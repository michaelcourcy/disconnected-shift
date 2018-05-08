echo "changing root password to root thus root/root"
echo -e "root\nroot" | passwd

echo "****************************************************"
echo "*      Install finish                              *"
echo "*                                                  *"
echo "* - reboot :  vagrant reload                       *"
echo "* - reconfigure VBox tool                          *"
echo "*      cd /opt/VBox*/init                          *"
echo "*      ./vboxadd setup                             *"
echo "*      now package a box from base_machine         *"
echo "*      vagrant halt                                *"
echo "*      vagrant package --output oc_base.box        *"
echo "****************************************************"