#include "ZeloPreCompiledHeader.h"

//#include <UI/Widgets/Texts/Text.h>
//#include <UI/Widgets/Drags/DragMultipleFloats.h>

#include "Core/ECS/Components/CTransform.h"
#include "Core/ECS/Actor.h"

using namespace Zelo::Core::ECS::Components;

//CTransform::CTransform(ECS::Actor &owner, OvMaths::FVector3 localPosition,
//                                                OvMaths::FQuaternion localRotation, OvMaths::FVector3 localScale) :
//        AComponent(owner) {
//    m_transform.GenerateMatrices(localPosition, localRotation, localScale);
//}
//
std::string CTransform::GetName() {
    return "Transform";
}

CTransform::CTransform(Zelo::Core::ECS::Actor &owner) : AComponent(owner) {

}
//
//void CTransform::SetParent(CTransform &parent) {
//    m_transform.SetParent(parent.GetFTransform());
//}
//
//bool CTransform::RemoveParent() {
//    return m_transform.RemoveParent();
//}
//
//bool CTransform::HasParent() const {
//    return m_transform.HasParent();
//}
//
//void CTransform::SetLocalPosition(OvMaths::FVector3 newPosition) {
//    m_transform.SetLocalPosition(newPosition);
//}
//
//void CTransform::SetLocalRotation(OvMaths::FQuaternion newRotation) {
//    m_transform.SetLocalRotation(newRotation);
//}
//
//void CTransform::SetLocalScale(OvMaths::FVector3 newScale) {
//    m_transform.SetLocalScale(newScale);
//}
//
//void CTransform::TranslateLocal(const OvMaths::FVector3 &translation) {
//    m_transform.TranslateLocal(translation);
//}
//
//void CTransform::RotateLocal(const OvMaths::FQuaternion &rotation) {
//    m_transform.RotateLocal(rotation);
//}
//
//void CTransform::ScaleLocal(const OvMaths::FVector3 &scale) {
//    m_transform.ScaleLocal(scale);
//}
//
//const OvMaths::FVector3 &CTransform::GetLocalPosition() const {
//    return m_transform.GetLocalPosition();
//}
//
//const OvMaths::FQuaternion &CTransform::GetLocalRotation() const {
//    return m_transform.GetLocalRotation();
//}
//
//const OvMaths::FVector3 &CTransform::GetLocalScale() const {
//    return m_transform.GetLocalScale();
//}
//
//const OvMaths::FVector3 &CTransform::GetWorldPosition() const {
//    return m_transform.GetWorldPosition();
//}
//
//const OvMaths::FQuaternion &CTransform::GetWorldRotation() const {
//    return m_transform.GetWorldRotation();
//}
//
//const OvMaths::FVector3 &CTransform::GetWorldScale() const {
//    return m_transform.GetWorldScale();
//}
//
//const OvMaths::FMatrix4 &CTransform::GetLocalMatrix() const {
//    return m_transform.GetLocalMatrix();
//}
//
//const OvMaths::FMatrix4 &CTransform::GetWorldMatrix() const {
//    return m_transform.GetWorldMatrix();
//}
//
//OvMaths::FTransform &CTransform::GetFTransform() {
//    return m_transform;
//}
//
//OvMaths::FVector3 CTransform::GetWorldForward() const {
//    return m_transform.GetWorldForward();
//}
//
//OvMaths::FVector3 CTransform::GetWorldUp() const {
//    return m_transform.GetWorldUp();
//}
//
//OvMaths::FVector3 CTransform::GetWorldRight() const {
//    return m_transform.GetWorldRight();
//}
//
//OvMaths::FVector3 CTransform::GetLocalForward() const {
//    return m_transform.GetLocalForward();
//}
//
//OvMaths::FVector3 CTransform::GetLocalUp() const {
//    return m_transform.GetLocalUp();
//}
//
//OvMaths::FVector3 CTransform::GetLocalRight() const {
//    return m_transform.GetLocalRight();
//}
//
//void CTransform::OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
//    OvCore::Helpers::Serializer::SerializeVec3(doc, node, "position", GetLocalPosition());
//    OvCore::Helpers::Serializer::SerializeQuat(doc, node, "rotation", GetLocalRotation());
//    OvCore::Helpers::Serializer::SerializeVec3(doc, node, "scale", GetLocalScale());
//}
//
//void CTransform::OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
//    m_transform.GenerateMatrices
//            (
//                    OvCore::Helpers::Serializer::DeserializeVec3(doc, node, "position"),
//                    OvCore::Helpers::Serializer::DeserializeQuat(doc, node, "rotation"),
//                    OvCore::Helpers::Serializer::DeserializeVec3(doc, node, "scale")
//            );
//}
//
//void CTransform::OnInspector(OvUI::Internal::WidgetContainer &root) {
//    auto getRotation = [this] {
//        return OvMaths::FQuaternion::EulerAngles(GetLocalRotation());
//    };
//
//    auto setRotation = [this](OvMaths::FVector3 result) {
//        SetLocalRotation(OvMaths::FQuaternion(result));
//    };
//
//    OvCore::Helpers::GUIDrawer::DrawVec3(root, "Position", std::bind(&CTransform::GetLocalPosition, this),
//                                         std::bind(&CTransform::SetLocalPosition, this, std::placeholders::_1), 0.05f);
//    OvCore::Helpers::GUIDrawer::DrawVec3(root, "Rotation", getRotation, setRotation, 0.05f);
//    OvCore::Helpers::GUIDrawer::DrawVec3(root, "Scale", std::bind(&CTransform::GetLocalScale, this),
//                                         std::bind(&CTransform::SetLocalScale, this, std::placeholders::_1), 0.05f,
//                                         0.0001f);
//}
